import SwiftUI

enum AppTab: Hashable, CaseIterable, Identifiable {
    case dashboard
    case vehicles
    case defects
    case reports
    case settings

    var id: Self { self }

    @ViewBuilder
    var label: some View {
        switch self {
        case .dashboard:
            Label("Dashboard", systemImage: "rectangle.grid.2x2")
        case .vehicles:
            Label("Vehicles", systemImage: "box.truck")
        case .defects:
            Label("Defects", systemImage: "exclamationmark.triangle")
        case .reports:
            Label("Reports", systemImage: "doc.text")
        case .settings:
            Label("Settings", systemImage: "gearshape")
        }
    }
}

enum Route: Hashable {
    case vehicle(UUID)
    case editVehicle(UUID?)
    case newInspection(UUID?)
    case checklistItem(UUID)
    case defect(UUID)
    case maintenance
    case fleetManager
    case report(UUID)
    case paywall
}

extension View {
    func withAppDestinations() -> some View {
        navigationDestination(for: Route.self) { route in
            switch route {
            case .vehicle(let id):
                VehicleDetailView(vehicleID: id)
            case .editVehicle(let id):
                VehicleEditorView(vehicleID: id)
            case .newInspection(let vehicleID):
                InspectionWorkflowView(vehicleID: vehicleID)
            case .checklistItem(let itemID):
                ChecklistItemDetailView(checklistItemID: itemID)
            case .defect(let defectID):
                DefectManagementView(defectID: defectID)
            case .maintenance:
                MaintenanceTrackerView()
            case .fleetManager:
                FleetManagerView()
            case .report(let reportID):
                ReportDetailView(reportID: reportID)
            case .paywall:
                PaywallView()
            }
        }
    }
}
