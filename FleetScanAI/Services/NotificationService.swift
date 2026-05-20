import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class NotificationService {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var errorMessage: String?

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            authorizationStatus = granted ? .authorized : .denied
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func schedule(reminder: MaintenanceReminder, vehicleName: String) async throws {
        guard !reminder.completed else { return }

        if authorizationStatus == .notDetermined {
            await requestAuthorization()
        }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "\(vehicleName): \(reminder.category.displayName) \(FleetFormatters.dueText(for: reminder.dueDate).lowercased())."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }

    func cancel(reminder: MaintenanceReminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
}
