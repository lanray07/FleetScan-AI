import SwiftData
import SwiftUI

struct ReportDetailView: View {
    let reportID: UUID

    @Environment(SubscriptionStore.self) private var subscriptions
    @State private var shareItem: ShareItem?
    @Query private var reports: [InspectionReport]
    @Query private var inspections: [VehicleInspection]
    @Query private var vehicles: [Vehicle]
    @Query private var defects: [Defect]

    private var report: InspectionReport? {
        reports.first { $0.id == reportID }
    }

    private var inspection: VehicleInspection? {
        report.flatMap { selectedReport in
            inspections.first { $0.id == selectedReport.inspectionId }
        }
    }

    private var vehicle: Vehicle? {
        inspection.flatMap { selectedInspection in
            vehicles.first { $0.id == selectedInspection.vehicleId }
        }
    }

    var body: some View {
        Group {
            if let report {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        ReportPreviewView(report: report)

                        if let vehicle, let inspection {
                            VehicleCard(vehicle: vehicle)
                            InspectionCard(inspection: inspection, vehicleName: vehicle.name)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Summary")
                                .font(.title3.weight(.semibold))
                            Text(report.summary)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))

                        let reportDefects = defects.filter { $0.inspectionId == report.inspectionId }
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Defects")
                            if reportDefects.isEmpty {
                                Text("No defects recorded in this report.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(reportDefects) { defect in
                                    DefectCard(defect: defect)
                                }
                            }
                        }

                        if let url = report.pdfURL, subscriptions.canExportPDF {
                            Button {
                                shareItem = ShareItem(items: [url])
                            } label: {
                                Label("Export PDF", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        } else if report.pdfURL != nil {
                            NavigationLink(value: Route.paywall) {
                                Label("Upgrade for PDF Export", systemImage: "lock")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                    .padding()
                }
            } else {
                EmptyStateView(title: "Report not found", message: "This report may have been removed.", systemImage: "questionmark.folder")
                    .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(report?.title ?? "Report")
        .sheet(item: $shareItem) { item in
            ShareSheet(items: item.items)
        }
    }
}
