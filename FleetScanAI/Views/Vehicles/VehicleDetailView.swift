import SwiftData
import SwiftUI

struct VehicleDetailView: View {
    let vehicleID: UUID

    @Query private var vehicles: [Vehicle]
    @Query(sort: \VehicleInspection.date, order: .reverse) private var inspections: [VehicleInspection]
    @Query(sort: \Defect.createdAt, order: .reverse) private var defects: [Defect]
    @Query(sort: \MaintenanceReminder.dueDate) private var reminders: [MaintenanceReminder]

    private var vehicle: Vehicle? {
        vehicles.first { $0.id == vehicleID }
    }

    var body: some View {
        Group {
            if let vehicle {
                VehicleDetailContent(
                    vehicle: vehicle,
                    inspections: inspections.filter { $0.vehicleId == vehicle.id },
                    defects: defects.filter { $0.vehicleId == vehicle.id && $0.status != .resolved },
                    reminders: reminders.filter { $0.vehicleId == vehicle.id && !$0.completed }
                )
            } else {
                EmptyStateView(title: "Vehicle not found", message: "This vehicle may have been deleted.", systemImage: "questionmark.folder")
                    .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(vehicle?.name ?? "Vehicle")
        .toolbar {
            if let vehicle {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Route.editVehicle(vehicle.id)) {
                        Image(systemName: "pencil")
                    }
                    .accessibilityLabel("Edit vehicle")
                }
            }
        }
    }
}

private struct VehicleDetailContent: View {
    @Bindable var vehicle: Vehicle
    let inspections: [VehicleInspection]
    let defects: [Defect]
    let reminders: [MaintenanceReminder]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                VehicleCard(vehicle: vehicle)

                HStack {
                    NavigationLink(value: Route.newInspection(vehicle.id)) {
                        Label("Start Check", systemImage: "checklist")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Toggle(isOn: $vehicle.isRoadworthy) {
                        Text("Roadworthy")
                    }
                    .labelsHidden()
                    .toggleStyle(.switch)
                }

                detailSection("Compliance") {
                    DetailRow(title: "MOT expiry", value: vehicle.motExpiryDate.map { FleetFormatters.shortDate.string(from: $0) } ?? "Not set")
                    DetailRow(title: "Insurance expiry", value: vehicle.insuranceExpiryDate.map { FleetFormatters.shortDate.string(from: $0) } ?? "Not set")
                    DetailRow(title: "Service due", value: vehicle.serviceDueDate.map { FleetFormatters.shortDate.string(from: $0) } ?? "Not set")
                }

                detailSection("Notes") {
                    Text(vehicle.notes.isEmpty ? "No notes recorded." : vehicle.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                detailSection("Open Defects") {
                    if defects.isEmpty {
                        Text("No open defects.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(defects) { defect in
                            NavigationLink(value: Route.defect(defect.id)) {
                                DefectCard(defect: defect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                detailSection("Maintenance") {
                    if reminders.isEmpty {
                        Text("No active reminders.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(reminders.prefix(4)) { reminder in
                            MaintenanceReminderCard(reminder: reminder, vehicleName: vehicle.name)
                        }
                    }
                    NavigationLink(value: Route.maintenance) {
                        Label("Manage Reminders", systemImage: "bell.badge")
                    }
                }

                detailSection("Inspection History") {
                    if inspections.isEmpty {
                        Text("No inspections logged.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(inspections.prefix(8)) { inspection in
                            InspectionCard(inspection: inspection, vehicleName: vehicle.name)
                        }
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func detailSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title)
            content()
        }
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.vertical, 4)
    }
}
