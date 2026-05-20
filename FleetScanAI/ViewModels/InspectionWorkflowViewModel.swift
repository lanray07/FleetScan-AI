import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class InspectionWorkflowViewModel {
    var isScanning = false
    var isFinalizing = false
    var errorMessage: String?
    var generatedReportID: UUID?

    func beginInspection(
        vehicle: Vehicle,
        driverName: String,
        mileage: Int,
        notes: String,
        context: ModelContext
    ) throws -> VehicleInspection {
        let inspection = VehicleInspection(
            vehicleId: vehicle.id,
            inspectionType: .dailyWalkaround,
            date: Date(),
            status: .draft,
            mileage: mileage,
            driverName: driverName,
            notes: notes
        )
        context.insert(inspection)

        let templates = FleetScanChecklist.dailyWalkaround.filter { template in
            !template.trailerOnly || vehicle.vehicleType == .trailer || vehicle.vehicleType == .truck || vehicle.vehicleType == .lorry
        }

        for template in templates {
            context.insert(ChecklistItem(
                inspectionId: inspection.id,
                title: template.title,
                category: template.category
            ))
        }

        vehicle.mileage = max(vehicle.mileage, mileage)
        try context.save()
        return inspection
    }

    func scanPhotos(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        photos: [VehiclePhoto],
        existingDefects: [Defect],
        aiService: any AIService,
        context: ModelContext
    ) async {
        guard !photos.isEmpty else {
            errorMessage = "Add at least one checklist photo before running AI scan."
            return
        }

        isScanning = true
        errorMessage = nil
        let existingPhotoIDs = Set(existingDefects.compactMap(\.photoId))

        do {
            for photo in photos where !existingPhotoIDs.contains(photo.id) {
                let checklistItem = items.first { $0.id == photo.checklistItemId }
                let request = AIScanRequest(
                    vehicleType: vehicle.vehicleType.rawValue,
                    inspectionType: inspection.inspectionType.rawValue,
                    checklistItem: checklistItem?.title ?? "Vehicle photo",
                    userNotes: [checklistItem?.notes, inspection.notes].compactMap { $0 }.joined(separator: " "),
                    imageBase64: photo.imageData?.base64EncodedString() ?? ""
                )
                let response = try await aiService.scanVehiclePhoto(request: request)

                for suggestion in response.defects {
                    context.insert(Defect(
                        vehicleId: vehicle.id,
                        inspectionId: inspection.id,
                        photoId: photo.id,
                        title: suggestion.title,
                        description: suggestion.description,
                        category: suggestion.category,
                        severity: suggestion.severity,
                        confidence: suggestion.confidence,
                        suggestedAction: suggestion.suggestedAction
                    ))
                }
            }
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }

        isScanning = false
    }

    func finalizeInspection(
        vehicle: Vehicle,
        inspection: VehicleInspection,
        items: [ChecklistItem],
        defects: [Defect],
        photos: [VehiclePhoto],
        aiService: any AIService,
        context: ModelContext,
        pdfService: PDFReportService,
        businessName: String,
        businessDetails: String,
        reportBranding: String
    ) async {
        isFinalizing = true
        errorMessage = nil

        do {
            let failedChecklist = items.contains { $0.passed == false }
            let criticalDefects = defects.contains { $0.status != .resolved && ($0.severity == .critical || $0.severity == .high) }
            inspection.status = failedChecklist || criticalDefects ? .failed : .passed
            vehicle.isRoadworthy = !criticalDefects

            let summary = try await aiService.generateInspectionSummary(
                vehicle: vehicle,
                inspection: inspection,
                items: items,
                defects: defects
            )

            let payload = PDFReportPayload(
                businessName: businessName,
                businessDetails: businessDetails,
                reportBranding: reportBranding,
                vehicle: vehicle,
                inspection: inspection,
                checklistItems: items,
                defects: defects,
                photos: photos,
                summary: summary
            )
            let url = try pdfService.generateReport(payload: payload)
            let report = InspectionReport(
                inspectionId: inspection.id,
                title: "\(vehicle.registrationNumber) inspection",
                summary: summary,
                pdfLocalURL: url.path
            )
            context.insert(report)
            try context.save()
            generatedReportID = report.id
        } catch {
            errorMessage = error.localizedDescription
        }

        isFinalizing = false
    }
}
