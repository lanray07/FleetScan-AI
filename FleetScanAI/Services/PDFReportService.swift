import Foundation
import UIKit

struct PDFReportPayload {
    let businessName: String
    let businessDetails: String
    let reportBranding: String
    let vehicle: Vehicle
    let inspection: VehicleInspection
    let checklistItems: [ChecklistItem]
    let defects: [Defect]
    let photos: [VehiclePhoto]
    let summary: String
}

@MainActor
struct PDFReportService {
    func generateReport(payload: PDFReportPayload) throws -> URL {
        let directory = try reportsDirectory()
        let safeVehicle = payload.vehicle.registrationNumber.replacingOccurrences(of: " ", with: "-")
        let filename = "FleetScan-\(safeVehicle)-\(Int(payload.inspection.date.timeIntervalSince1970)).pdf"
        let url = directory.appendingPathComponent(filename)

        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        try renderer.writePDF(to: url) { context in
            var y: CGFloat = 36

            func newPageIfNeeded(_ required: CGFloat = 54) {
                if y + required > pageBounds.height - 40 {
                    context.beginPage()
                    y = 36
                }
            }

            func draw(_ text: String, font: UIFont, color: UIColor = .label, indent: CGFloat = 0, spacing: CGFloat = 8) {
                newPageIfNeeded()
                let rect = CGRect(x: 40 + indent, y: y, width: pageBounds.width - 80 - indent, height: 1000)
                let style = NSMutableParagraphStyle()
                style.lineBreakMode = .byWordWrapping
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: style
                ]
                let measured = text.boundingRect(
                    with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                text.draw(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: measured.height), withAttributes: attributes)
                y += measured.height + spacing
            }

            context.beginPage()

            draw(AppConstants.appName, font: .boldSystemFont(ofSize: 28), color: .systemBlue, spacing: 4)
            draw(payload.businessName.isEmpty ? "Vehicle Inspection Report" : payload.businessName, font: .boldSystemFont(ofSize: 18), spacing: 14)
            draw("Inspection date: \(FleetFormatters.shortDateTime.string(from: payload.inspection.date))", font: .systemFont(ofSize: 12))
            draw("Vehicle: \(payload.vehicle.name) - \(payload.vehicle.registrationNumber) - \(payload.vehicle.vehicleType.displayName)", font: .systemFont(ofSize: 12))
            draw("Mileage: \(payload.inspection.mileage)", font: .systemFont(ofSize: 12), spacing: 16)

            draw("Summary", font: .boldSystemFont(ofSize: 16), color: .systemBlue)
            draw(payload.summary, font: .systemFont(ofSize: 12), spacing: 16)

            draw("Checklist Results", font: .boldSystemFont(ofSize: 16), color: .systemBlue)
            for item in payload.checklistItems {
                let state = item.passed == true ? "PASS" : item.passed == false ? "FAIL" : "NOT SET"
                draw("\(state) - \(item.title) - \(item.severity.displayName) \(item.notes.isEmpty ? "" : "- \(item.notes)")", font: .systemFont(ofSize: 11), indent: 8, spacing: 5)
            }

            draw("Severity Breakdown", font: .boldSystemFont(ofSize: 16), color: .systemBlue, spacing: 6)
            for severity in Severity.allCases where severity != .none {
                let count = payload.defects.filter { $0.severity == severity }.count
                draw("\(severity.displayName): \(count)", font: .systemFont(ofSize: 11), indent: 8, spacing: 4)
            }

            draw("Defects and AI Findings", font: .boldSystemFont(ofSize: 16), color: .systemBlue, spacing: 6)
            if payload.defects.isEmpty {
                draw("No defects recorded.", font: .systemFont(ofSize: 11), indent: 8)
            } else {
                for defect in payload.defects {
                    let confidence = Int(defect.confidence * 100)
                    draw("\(defect.severity.displayName.uppercased()) - \(defect.title)", font: .boldSystemFont(ofSize: 12), indent: 8, spacing: 3)
                    draw("\(defect.defectDescription) Confidence: \(confidence)%. Suggested action: \(defect.suggestedAction)", font: .systemFont(ofSize: 11), indent: 8, spacing: 8)
                }
            }

            draw("Photo Evidence", font: .boldSystemFont(ofSize: 16), color: .systemBlue, spacing: 8)
            let usablePhotos = payload.photos.compactMap { photo -> (VehiclePhoto, UIImage)? in
                guard let data = photo.imageData, let image = UIImage(data: data) else { return nil }
                return (photo, image)
            }

            if usablePhotos.isEmpty {
                draw("No photos attached.", font: .systemFont(ofSize: 11), indent: 8)
            } else {
                for (photo, image) in usablePhotos.prefix(8) {
                    newPageIfNeeded(170)
                    let imageRect = CGRect(x: 48, y: y, width: 150, height: 110)
                    image.draw(in: imageRect)
                    draw(photo.caption.isEmpty ? "Vehicle photo" : photo.caption, font: .systemFont(ofSize: 10), indent: 170, spacing: 12)
                    y = max(y, imageRect.maxY + 12)
                }
            }

            draw("Driver Notes", font: .boldSystemFont(ofSize: 16), color: .systemBlue)
            draw(payload.inspection.notes.isEmpty ? "No driver notes." : payload.inspection.notes, font: .systemFont(ofSize: 11), spacing: 18)

            draw("Signature", font: .boldSystemFont(ofSize: 16), color: .systemBlue)
            draw("Driver signature: ______________________________    Date: ________________", font: .systemFont(ofSize: 11), spacing: 18)

            draw("Disclaimer", font: .boldSystemFont(ofSize: 16), color: .systemRed)
            draw(AppConstants.disclaimers.joined(separator: ". ") + ".", font: .systemFont(ofSize: 10), spacing: 12)

            if !payload.reportBranding.isEmpty {
                draw(payload.reportBranding, font: .italicSystemFont(ofSize: 10), color: .secondaryLabel)
            } else {
                draw("Generated by FleetScan AI. AI findings are suggestions and must be reviewed.", font: .italicSystemFont(ofSize: 10), color: .secondaryLabel)
            }
        }

        return url
    }

    private func reportsDirectory() throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("FleetScanReports", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }
}
