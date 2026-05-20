import SwiftData
import SwiftUI

struct DefectsListView: View {
    @Query(sort: \Defect.createdAt, order: .reverse) private var defects: [Defect]
    @State private var searchText = ""
    @State private var statusFilter: DefectStatus?

    private var filteredDefects: [Defect] {
        defects.filter { defect in
            let matchesStatus = statusFilter == nil || defect.status == statusFilter
            let matchesSearch = searchText.isEmpty ||
                defect.title.localizedCaseInsensitiveContains(searchText) ||
                defect.defectDescription.localizedCaseInsensitiveContains(searchText) ||
                defect.category.displayName.localizedCaseInsensitiveContains(searchText)
            return matchesStatus && matchesSearch
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                Picker("Status", selection: $statusFilter) {
                    Text("All").tag(Optional<DefectStatus>.none)
                    ForEach(DefectStatus.allCases) { status in
                        Text(status.displayName).tag(Optional(status))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 4)

                if filteredDefects.isEmpty {
                    EmptyStateView(title: "No defects", message: "AI findings, failed checklist items, and repair tracking will appear here.", systemImage: "exclamationmark.triangle")
                        .padding(.top, 16)
                } else {
                    ForEach(filteredDefects) { defect in
                        NavigationLink(value: Route.defect(defect.id)) {
                            DefectCard(defect: defect)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Defects")
        .searchable(text: $searchText, prompt: "Search defects")
    }
}
