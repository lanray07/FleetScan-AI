import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct ChecklistItemDetailView: View {
    let checklistItemID: UUID

    @Environment(\.modelContext) private var modelContext
    @Query private var checklistItems: [ChecklistItem]
    @Query(sort: \VehiclePhoto.createdAt, order: .reverse) private var photos: [VehiclePhoto]

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCamera = false

    private var checklistItem: ChecklistItem? {
        checklistItems.first { $0.id == checklistItemID }
    }

    private var itemPhotos: [VehiclePhoto] {
        photos.filter { $0.checklistItemId == checklistItemID }
    }

    var body: some View {
        Group {
            if let checklistItem {
                ChecklistItemEditor(
                    checklistItem: checklistItem,
                    photos: itemPhotos,
                    selectedPhotoItem: $selectedPhotoItem,
                    showingCamera: $showingCamera,
                    addCameraImage: addCameraImage
                )
            } else {
                EmptyStateView(title: "Checklist item not found", message: "This item may have been removed.", systemImage: "questionmark.folder")
                    .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(checklistItem?.title ?? "Checklist")
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task { await addPhoto(from: newItem) }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker { image in
                addCameraImage(image)
            }
        }
    }

    private func addPhoto(from photoItem: PhotosPickerItem?) async {
        guard let checklistItem, let photoItem else { return }
        do {
            guard let data = try await photoItem.loadTransferable(type: Data.self) else { return }
            modelContext.insert(VehiclePhoto(
                inspectionId: checklistItem.inspectionId,
                checklistItemId: checklistItem.id,
                imageData: data,
                caption: checklistItem.title
            ))
            try modelContext.save()
            selectedPhotoItem = nil
        } catch {
            selectedPhotoItem = nil
        }
    }

    private func addCameraImage(_ image: UIImage) {
        guard let checklistItem, let data = image.jpegData(compressionQuality: 0.82) else { return }
        modelContext.insert(VehiclePhoto(
            inspectionId: checklistItem.inspectionId,
            checklistItemId: checklistItem.id,
            imageData: data,
            caption: checklistItem.title
        ))
        try? modelContext.save()
    }
}

private struct ChecklistItemEditor: View {
    @Bindable var checklistItem: ChecklistItem
    let photos: [VehiclePhoto]
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var showingCamera: Bool
    let addCameraImage: (UIImage) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Result")
                        .font(.title3.weight(.semibold))

                    Picker("Pass or fail", selection: Binding(
                        get: { checklistItem.passed },
                        set: { checklistItem.passed = $0 }
                    )) {
                        Text("Not checked").tag(Optional<Bool>.none)
                        Text("Pass").tag(Optional(true))
                        Text("Fail").tag(Optional(false))
                    }
                    .pickerStyle(.segmented)

                    Picker("Severity", selection: $checklistItem.severity) {
                        ForEach(Severity.allCases) { severity in
                            Text(severity.displayName).tag(severity)
                        }
                    }

                    TextEditor(text: $checklistItem.notes)
                        .frame(minHeight: 110)
                        .overlay(alignment: .topLeading) {
                            if checklistItem.notes.isEmpty {
                                Text("Notes")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Photo Evidence")
                    HStack {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Upload Photo", systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            showingCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    if photos.isEmpty {
                        EmptyStateView(title: "No photos", message: "Attach tyre, body, light, dashboard, or repair evidence for AI review.", systemImage: "photo")
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(photos) { photo in
                                if let data = photo.imageData {
                                    PhotoThumbnail(data: data)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
