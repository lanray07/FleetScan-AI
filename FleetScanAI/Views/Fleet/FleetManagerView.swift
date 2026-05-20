import SwiftData
import SwiftUI

struct FleetManagerView: View {
    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]
    @Query(sort: \Defect.createdAt, order: .reverse) private var defects: [Defect]
    @Query(sort: \VehicleInspection.date, order: .reverse) private var inspections: [VehicleInspection]

    private var openDefects: [Defect] {
        defects.filter { $0.status != .resolved }
    }

    private var failedChecks: [VehicleInspection] {
        inspections.filter { $0.status == .failed }
    }

    private var urgentVehicles: [Vehicle] {
        let urgentVehicleIDs = Set(openDefects.filter { $0.severity == .critical || $0.severity == .high }.map(\.vehicleId))
        return vehicles.filter { urgentVehicleIDs.contains($0.id) || !$0.isRoadworthy }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricTile(title: "All vehicles", value: "\(vehicles.count)", systemImage: "box.truck", color: .blue)
                    MetricTile(title: "Open defects", value: "\(openDefects.count)", systemImage: "wrench.and.screwdriver", color: .orange)
                    MetricTile(title: "Failed checks", value: "\(failedChecks.count)", systemImage: "xmark.octagon", color: .red)
                    MetricTile(title: "Urgent vehicles", value: "\(urgentVehicles.count)", systemImage: "exclamationmark.triangle", color: .red)
                }

                managerSection("Urgent Vehicles") {
                    if urgentVehicles.isEmpty {
                        EmptyStateView(title: "No urgent vehicles", message: "Critical defects and not-roadworthy vehicles are clear.", systemImage: "checkmark.seal")
                    } else {
                        ForEach(urgentVehicles) { vehicle in
                            NavigationLink(value: Route.vehicle(vehicle.id)) {
                                VehicleCard(vehicle: vehicle)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                managerSection("Driver-submitted Reports") {
                    if inspections.isEmpty {
                        EmptyStateView(title: "No reports yet", message: "Submitted daily checks will appear here for manager review.", systemImage: "person.text.rectangle")
                    } else {
                        ForEach(inspections.prefix(10)) { inspection in
                            InspectionCard(inspection: inspection, vehicleName: vehicleName(for: inspection.vehicleId))
                        }
                    }
                }

                managerSection("Open Defects") {
                    if openDefects.isEmpty {
                        Text("No open defects.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(openDefects.prefix(10)) { defect in
                            NavigationLink(value: Route.defect(defect.id)) {
                                DefectCard(defect: defect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                managerSection("Inspection History") {
                    ForEach(inspections.prefix(12)) { inspection in
                        InspectionCard(inspection: inspection, vehicleName: vehicleName(for: inspection.vehicleId))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Fleet Manager")
    }

    private func vehicleName(for id: UUID) -> String {
        vehicles.first { $0.id == id }?.name ?? "Unknown vehicle"
    }

    @ViewBuilder
    private func managerSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            content()
        }
    }
}
