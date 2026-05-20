import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage("businessName") private var businessName = ""
    @AppStorage("businessDetails") private var businessDetails = ""
    @AppStorage("reportBranding") private var reportBranding = ""
    @AppStorage("usesRemoteAI") private var usesRemoteAI = false

    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionStore.self) private var subscriptions

    @Query private var vehicles: [Vehicle]
    @Query private var inspections: [VehicleInspection]
    @Query private var checklistItems: [ChecklistItem]
    @Query private var photos: [VehiclePhoto]
    @Query private var defects: [Defect]
    @Query private var reminders: [MaintenanceReminder]
    @Query private var reports: [InspectionReport]
    @Query private var subscriptionStates: [SubscriptionState]

    @State private var showingDeleteConfirmation = false
    @State private var shareItem: ShareItem?

    var body: some View {
        Form {
            Section("Subscription") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(subscriptions.statusText)
                        .foregroundStyle(.secondary)
                }
                NavigationLink(value: Route.paywall) {
                    Label("Manage Plan", systemImage: "creditcard")
                }
                Button {
                    Task { await subscriptions.openManageSubscriptions() }
                } label: {
                    Label("Manage App Store Subscription", systemImage: "arrow.up.forward.app")
                }
            }

            Section("Business Profile") {
                TextField("Business name", text: $businessName)
                TextEditor(text: $businessDetails)
                    .frame(minHeight: 90)
            }

            Section("Report Branding") {
                TextField("Footer or branding line", text: $reportBranding)
                Toggle("Use remote AI endpoint", isOn: $usesRemoteAI)
                Text("Remote AI sends requests to \(AppConstants.backendEndpoint). Never store API keys in the iOS app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Legal and Safety") {
                DisclosureGroup("AI Disclaimer") {
                    ForEach(AppConstants.disclaimers, id: \.self) { disclaimer in
                        Text(disclaimer)
                            .font(.subheadline)
                    }
                }
                NavigationLink("Privacy Policy") {
                    LegalTextView(title: "Privacy Policy", bodyText: "FleetScan AI stores inspection data locally using SwiftData by default. Configure your backend privacy terms before production release.")
                }
                NavigationLink("Terms of Use") {
                    LegalTextView(title: "Terms of Use", bodyText: "FleetScan AI provides workflow support only. AI outputs are suggestions and are not legal, MOT, roadworthiness, or mechanical certification.")
                }
            }

            Section("Data") {
                Button {
                    exportReports()
                } label: {
                    Label("Export Reports", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete All Local Data", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Delete all local FleetScan AI data?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete All Data", role: .destructive, action: deleteAllLocalData)
            Button("Cancel", role: .cancel) {}
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: item.items)
        }
    }

    private func exportReports() {
        let urls = reports.compactMap { report -> URL? in
            guard let path = report.pdfLocalURL else { return nil }
            return URL(fileURLWithPath: path)
        }
        guard !urls.isEmpty else { return }
        shareItem = ShareItem(items: urls)
    }

    private func deleteAllLocalData() {
        vehicles.forEach { modelContext.delete($0) }
        inspections.forEach { modelContext.delete($0) }
        checklistItems.forEach { modelContext.delete($0) }
        photos.forEach { modelContext.delete($0) }
        defects.forEach { modelContext.delete($0) }
        reminders.forEach { modelContext.delete($0) }
        reports.forEach { modelContext.delete($0) }
        subscriptionStates.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
}

private struct LegalTextView: View {
    let title: String
    let bodyText: String

    var body: some View {
        ScrollView {
            Text(bodyText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
    }
}
