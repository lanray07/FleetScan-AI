import Foundation
import Observation

@MainActor
@Observable
final class ReportsViewModel {
    var searchText = ""
    var selectedSeverity: Severity?

    func filteredReports(
        reports: [InspectionReport],
        inspections: [VehicleInspection],
        vehicles: [Vehicle],
        defects: [Defect]
    ) -> [InspectionReport] {
        reports
            .filter { report in
                let inspection = inspections.first { $0.id == report.inspectionId }
                let vehicle = inspection.flatMap { selectedInspection in
                    vehicles.first { $0.id == selectedInspection.vehicleId }
                }
                let reportDefects = defects.filter { $0.inspectionId == report.inspectionId }
                let matchesSearch = searchText.isEmpty ||
                    report.title.localizedCaseInsensitiveContains(searchText) ||
                    report.summary.localizedCaseInsensitiveContains(searchText) ||
                    (vehicle?.registrationNumber.localizedCaseInsensitiveContains(searchText) ?? false) ||
                    (vehicle?.name.localizedCaseInsensitiveContains(searchText) ?? false)
                let matchesSeverity = selectedSeverity == nil || reportDefects.contains { $0.severity == selectedSeverity }
                return matchesSearch && matchesSeverity
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
}
