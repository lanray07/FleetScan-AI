import SwiftData
import SwiftUI

@main
@MainActor
struct FleetScanAIApp: App {
    @AppStorage("usesRemoteAI") private var usesRemoteAI = false
    @State private var subscriptions = SubscriptionStore()
    @State private var notifications = NotificationService()

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Vehicle.self,
                VehicleInspection.self,
                ChecklistItem.self,
                VehiclePhoto.self,
                Defect.self,
                MaintenanceReminder.self,
                InspectionReport.self,
                SubscriptionState.self
            )
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
                .environment(subscriptions)
                .environment(notifications)
                .environment(\.aiService, selectedAIService)
        }
    }

    private var selectedAIService: any AIService {
        if usesRemoteAI {
            return RemoteAIService()
        }
        return MockAIService()
    }
}
