import SwiftData
import SwiftUI

struct ReportsCenterView: View {
    @Environment(SubscriptionStore.self) private var subscriptions
    @State private var viewModel = ReportsViewModel()
    @State private var shareItem: ShareItem?

    @Query(sort: \InspectionReport.createdAt, order: .reverse) private var reports: [InspectionReport]
    @Query private var inspections: [VehicleInspection]
    @Query private var vehicles: [Vehicle]
    @Query private var defects: [Defect]

    private var filteredReports: [InspectionReport] {
        viewModel.filteredReports(reports: reports, inspections: inspections, vehicles: vehicles, defects: defects)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                Picker("Severity", selection: $viewModel.selectedSeverity) {
                    Text("All").tag(Optional<Severity>.none)
                    ForEach(Severity.allCases.filter { $0 != .none }) { severity in
                        Text(severity.displayName).tag(Optional(severity))
                    }
                }
                .pickerStyle(.segmented)

                if filteredReports.isEmpty {
                    EmptyStateView(title: "No reports", message: "Generate a PDF from a completed inspection to save it here.", systemImage: "doc.text")
                        .padding(.top, 16)
                } else {
                    ForEach(filteredReports) { report in
                        HStack(alignment: .center, spacing: 10) {
                            NavigationLink(value: Route.report(report.id)) {
                                ReportPreviewView(report: report)
                            }
                            .buttonStyle(.plain)

                            if let url = report.pdfURL, subscriptions.canExportPDF {
                                Button {
                                    shareItem = ShareItem(items: [url])
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .buttonStyle(.bordered)
                            } else if report.pdfURL != nil {
                                NavigationLink(value: Route.paywall) {
                                    Image(systemName: "lock")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reports")
        .searchable(text: $viewModel.searchText, prompt: "Search vehicle, date, severity")
        .sheet(item: $shareItem) { item in
            ShareSheet(items: item.items)
        }
        .toolbar {
            if !subscriptions.canExportPDF {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Route.paywall) {
                        Image(systemName: "lock.open")
                    }
                    .accessibilityLabel("Upgrade for PDF exports")
                }
            }
        }
    }
}
