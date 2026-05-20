import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(SubscriptionStore.self) private var subscriptions
    @State private var viewModel = DashboardViewModel()

    @Query(sort: \Vehicle.createdAt, order: .reverse) private var vehicles: [Vehicle]
    @Query(sort: \VehicleInspection.date, order: .reverse) private var inspections: [VehicleInspection]
    @Query(sort: \Defect.createdAt, order: .reverse) private var defects: [Defect]
    @Query(sort: \MaintenanceReminder.dueDate) private var reminders: [MaintenanceReminder]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fleet dashboard")
                        .font(.largeTitle.weight(.bold))
                    Text("Daily checks, defects, reminders, and reports in one place.")
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricTile(title: "Vehicles", value: "\(vehicles.count)", systemImage: "box.truck", color: .blue)
                    MetricTile(title: "Open defects", value: "\(openDefects.count)", systemImage: "exclamationmark.triangle", color: .orange)
                    MetricTile(title: "Due checks", value: "\(dueVehicles.count)", systemImage: "clock.badge.exclamationmark", color: .red)
                    MetricTile(title: "Plan", value: subscriptions.plan.displayName, systemImage: "creditcard", color: .green)
                }

                NavigationLink(value: Route.newInspection(vehicles.first?.id)) {
                    Label("New Vehicle Check", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if !subscriptions.canUseAIDefectScanning {
                    NavigationLink(value: Route.paywall) {
                        UpgradeBanner(
                            title: "Unlock AI defect scanning and PDF exports",
                            message: "Pro adds AI scan suggestions, maintenance reminders, unlimited inspections, and branded reports."
                        )
                    }
                    .buttonStyle(.plain)
                }

                dashboardSection("Recent Inspections") {
                    if recentInspections.isEmpty {
                        EmptyStateView(title: "No inspections yet", message: "Start a daily walkaround check to build a compliance record.", systemImage: "checklist")
                    } else {
                        ForEach(recentInspections) { inspection in
                            InspectionCard(inspection: inspection, vehicleName: vehicleName(for: inspection.vehicleId))
                        }
                    }
                }

                dashboardSection("Open Defects") {
                    if openDefects.isEmpty {
                        EmptyStateView(title: "No open defects", message: "Approved AI findings and failed checklist items will appear here.", systemImage: "wrench.and.screwdriver")
                    } else {
                        ForEach(openDefects.prefix(4)) { defect in
                            NavigationLink(value: Route.defect(defect.id)) {
                                DefectCard(defect: defect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                dashboardSection("Vehicles Due for Check") {
                    if dueVehicles.isEmpty {
                        EmptyStateView(title: "Checks are current", message: "Every vehicle has an inspection logged today.", systemImage: "checkmark.seal")
                    } else {
                        ForEach(dueVehicles.prefix(4)) { vehicle in
                            NavigationLink(value: Route.newInspection(vehicle.id)) {
                                VehicleCard(vehicle: vehicle)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                dashboardSection("Maintenance Reminders") {
                    if dueReminders.isEmpty {
                        EmptyStateView(title: "No urgent reminders", message: "MOT, insurance, service, tyres, brakes, and oil reminders will show here.", systemImage: "bell")
                    } else {
                        ForEach(dueReminders.prefix(4)) { reminder in
                            MaintenanceReminderCard(reminder: reminder, vehicleName: vehicleName(for: reminder.vehicleId))
                        }
                    }
                }

                NavigationLink(value: Route.fleetManager) {
                    Label("Fleet Manager View", systemImage: "person.3.sequence.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.paywall) {
                    Image(systemName: "sparkles")
                }
                .accessibilityLabel("Subscription")
            }
        }
    }

    private var recentInspections: [VehicleInspection] {
        viewModel.recentInspections(inspections)
    }

    private var openDefects: [Defect] {
        viewModel.openDefects(defects)
    }

    private var dueVehicles: [Vehicle] {
        viewModel.vehiclesDueForCheck(vehicles: vehicles, inspections: inspections)
    }

    private var dueReminders: [MaintenanceReminder] {
        viewModel.dueReminders(reminders)
    }

    private func vehicleName(for id: UUID) -> String {
        vehicles.first { $0.id == id }?.name ?? "Unknown vehicle"
    }

    @ViewBuilder
    private func dashboardSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            content()
        }
    }
}
