import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class DashboardViewModel {
    var errorMessage: String?

    func vehiclesDueForCheck(vehicles: [Vehicle], inspections: [VehicleInspection]) -> [Vehicle] {
        let calendar = Calendar.current
        return vehicles.filter { vehicle in
            guard let latest = inspections
                .filter({ $0.vehicleId == vehicle.id })
                .max(by: { $0.date < $1.date }) else {
                return true
            }
            return !calendar.isDateInToday(latest.date)
        }
    }

    func recentInspections(_ inspections: [VehicleInspection]) -> [VehicleInspection] {
        Array(inspections.sorted { $0.date > $1.date }.prefix(5))
    }

    func openDefects(_ defects: [Defect]) -> [Defect] {
        defects.filter { $0.status != .resolved }.sorted { $0.severity > $1.severity }
    }

    func dueReminders(_ reminders: [MaintenanceReminder]) -> [MaintenanceReminder] {
        reminders
            .filter { !$0.completed && ($0.dueDate.isOverdue || $0.dueDate.isWithinNextThirtyDays) }
            .sorted { $0.dueDate < $1.dueDate }
    }
}
