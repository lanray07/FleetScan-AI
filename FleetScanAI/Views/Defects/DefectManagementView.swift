import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct DefectManagementView: View {
    let defectID: UUID

    @Environment(\.modelContext) private var modelContext
    @Query private var defects: [Defect]
    @Query private var vehicles: [Vehicle]

    @State private var beforePhotoItem: PhotosPickerItem?
    @State private var afterPhotoItem: PhotosPickerItem?

    private var defect: Defect? {
        defects.first { $0.id == defectID }
    }

    private var vehicle: Vehicle? {
        defect.flatMap { selectedDefect in
            vehicles.first { $0.id == selectedDefect.vehicleId }
        }
    }

    var body: some View {
        Group {
            if let defect {
                DefectEditor(defect: defect, vehicle: vehicle)
            } else {
                EmptyStateView(title: "Defect not found", message: "This defect may have been deleted.", systemImage: "questionmark.folder")
                    .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(defect?.title ?? "Defect")
        .onChange(of: beforePhotoItem) { _, item in
            Task { await loadRepairPhoto(item, before: true) }
        }
        .onChange(of: afterPhotoItem) { _, item in
            Task { await loadRepairPhoto(item, before: false) }
        }
        .toolbar {
            if defect != nil {
                ToolbarItemGroup(placement: .bottomBar) {
                    PhotosPicker(selection: $beforePhotoItem, matching: .images) {
                        Label("Before", systemImage: "photo.badge.plus")
                    }
                    Spacer()
                    PhotosPicker(selection: $afterPhotoItem, matching: .images) {
                        Label("After", systemImage: "photo.stack")
                    }
                }
            }
        }
    }

    private func loadRepairPhoto(_ item: PhotosPickerItem?, before: Bool) async {
        guard let item, let defect else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        if before {
            defect.beforeRepairPhotoData = data
            beforePhotoItem = nil
        } else {
            defect.afterRepairPhotoData = data
            afterPhotoItem = nil
        }
        try? modelContext.save()
    }
}

private struct DefectEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var defect: Defect
    var vehicle: Vehicle?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        SeverityBadge(severity: defect.severity)
                        Spacer()
                        Text("AI \(Int(defect.confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    TextField("Defect title", text: $defect.title)
                        .textFieldStyle(.roundedBorder)

                    Picker("Category", selection: $defect.category) {
                        ForEach(DefectCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }

                    Picker("Severity", selection: $defect.severity) {
                        ForEach(Severity.allCases.filter { $0 != .none }) { severity in
                            Text(severity.displayName).tag(severity)
                        }
                    }

                    Picker("Repair priority", selection: $defect.repairPriority) {
                        ForEach(Severity.allCases.filter { $0 != .none }) { severity in
                            Text(severity.displayName).tag(severity)
                        }
                    }

                    Picker("Status", selection: $defect.status) {
                        ForEach(DefectStatus.allCases) { status in
                            Text(status.displayName).tag(status)
                        }
                    }

                    Toggle("Approve AI finding", isOn: $defect.userApproved)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.title3.weight(.semibold))
                    TextEditor(text: $defect.defectDescription)
                        .frame(minHeight: 120)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Suggested Action")
                        .font(.title3.weight(.semibold))
                    TextEditor(text: $defect.suggestedAction)
                        .frame(minHeight: 90)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))

                if let vehicle {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vehicle Roadworthiness")
                            .font(.title3.weight(.semibold))
                        Toggle("Vehicle marked roadworthy", isOn: Binding(
                            get: { vehicle.isRoadworthy },
                            set: {
                                vehicle.isRoadworthy = $0
                                try? modelContext.save()
                            }
                        ))
                        Text(AppConstants.disclaimers.joined(separator: ". "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Repair Notes")
                        .font(.title3.weight(.semibold))
                    TextEditor(text: $defect.repairNotes)
                        .frame(minHeight: 110)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        if let before = defect.beforeRepairPhotoData {
                            VStack(alignment: .leading) {
                                Text("Before")
                                    .font(.caption.weight(.semibold))
                                PhotoThumbnail(data: before)
                            }
                        }
                        if let after = defect.afterRepairPhotoData {
                            VStack(alignment: .leading) {
                                Text("After")
                                    .font(.caption.weight(.semibold))
                                PhotoThumbnail(data: after)
                            }
                        }
                    }

                    Button {
                        defect.status = .resolved
                        defect.resolvedAt = Date()
                        try? modelContext.save()
                    } label: {
                        Label("Mark Resolved", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
    }
}
