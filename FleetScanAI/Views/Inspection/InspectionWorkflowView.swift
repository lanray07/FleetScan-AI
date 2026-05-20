import SwiftData
import SwiftUI

struct InspectionWorkflowView: View {
    let vehicleID: UUID?

    @AppStorage("businessName") private var businessName = ""
    @AppStorage("businessDetails") private var businessDetails = ""
    @AppStorage("reportBranding") private var reportBranding = ""

    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Environment(SubscriptionStore.self) private var subscriptions
    @State private var viewModel = InspectionWorkflowViewModel()

    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]
    @Query(sort: \VehicleInspection.date, order: .reverse) private var inspections: [VehicleInspection]
    @Query private var checklistItems: [ChecklistItem]
    @Query(sort: \VehiclePhoto.createdAt, order: .reverse) private var photos: [VehiclePhoto]
    @Query(sort: \Defect.createdAt, order: .reverse) private var defects: [Defect]

    @State private var selectedVehicleID: UUID?
    @State private var driverName = ""
    @State private var mileage = 0
    @State private var notes = ""
    @State private var currentInspectionID: UUID?

    private var selectedVehicle: Vehicle? {
        guard let selectedVehicleID else { return nil }
        return vehicles.first { $0.id == selectedVehicleID }
    }

    private var currentInspection: VehicleInspection? {
        guard let currentInspectionID else { return nil }
        return inspections.first { $0.id == currentInspectionID }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                if vehicles.isEmpty {
                    EmptyStateView(title: "Add a vehicle first", message: "A daily walkaround check needs a vehicle profile.", systemImage: "box.truck")
                    NavigationLink(value: Route.editVehicle(nil)) {
                        Label("Add Vehicle", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else if let inspection = currentInspection, let vehicle = selectedVehicle {
                    activeInspectionView(inspection: inspection, vehicle: vehicle)
                } else {
                    startForm
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Daily Check")
        .onAppear {
            selectedVehicleID = vehicleID ?? selectedVehicleID ?? vehicles.first?.id
            if let selectedVehicle {
                mileage = max(mileage, selectedVehicle.mileage)
            }
        }
        .alert("Inspection Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var startForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Start Daily Walkaround")
                .font(.largeTitle.weight(.bold))
            Text("Record driver details, capture checklist photos, run mock AI suggestions, and generate a PDF report.")
                .foregroundStyle(.secondary)

            if isBlockedByInspectionLimit {
                NavigationLink(value: Route.paywall) {
                    UpgradeBanner(
                        title: "Inspection limit reached",
                        message: "Free includes 5 inspections per month. Pro and Business plans unlock unlimited inspections."
                    )
                }
                .buttonStyle(.plain)
            }

            Picker("Vehicle", selection: $selectedVehicleID) {
                ForEach(vehicles) { vehicle in
                    Text("\(vehicle.name) - \(vehicle.registrationNumber)").tag(Optional(vehicle.id))
                }
            }
            .pickerStyle(.navigationLink)

            TextField("Driver name", text: $driverName)
                .textFieldStyle(.roundedBorder)

            Stepper("Mileage: \(mileage)", value: $mileage, in: 0...2_000_000, step: 100)

            TextEditor(text: $notes)
                .frame(minHeight: 110)
                .overlay(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Driver notes")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                }

            Button {
                beginInspection()
            } label: {
                Label("Begin Checklist", systemImage: "checklist")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(selectedVehicle == nil || isBlockedByInspectionLimit)
        }
    }

    @ViewBuilder
    private func activeInspectionView(inspection: VehicleInspection, vehicle: Vehicle) -> some View {
        let items = checklistItems
            .filter { $0.inspectionId == inspection.id }
            .sorted { $0.title < $1.title }
        let inspectionPhotos = photos.filter { $0.inspectionId == inspection.id }
        let inspectionDefects = defects.filter { $0.inspectionId == inspection.id }

        VStack(alignment: .leading, spacing: 16) {
            VehicleCard(vehicle: vehicle)

            InspectionHeaderEditor(inspection: inspection)

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Checklist")
                ForEach(items) { item in
                    NavigationLink(value: Route.checklistItem(item.id)) {
                        ChecklistRow(item: item)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "AI Defect Scan")
                Text("Mock AI mode is enabled by default. Suggestions use cautious language and require review before approval.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    Task {
                        await viewModel.scanPhotos(
                            vehicle: vehicle,
                            inspection: inspection,
                            items: items,
                            photos: inspectionPhotos,
                            existingDefects: inspectionDefects,
                            aiService: aiService,
                            context: modelContext
                        )
                    }
                } label: {
                    if viewModel.isScanning {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Label("Scan Uploaded Photos", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isScanning || inspectionPhotos.isEmpty)

                if inspectionDefects.isEmpty {
                    EmptyStateView(title: "No AI findings yet", message: "Add photos to checklist items, then run the mock AI scan.", systemImage: "camera.metering.center.weighted")
                } else {
                    ForEach(inspectionDefects) { defect in
                        NavigationLink(value: Route.defect(defect.id)) {
                            DefectCard(defect: defect)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                Task {
                    await viewModel.finalizeInspection(
                        vehicle: vehicle,
                        inspection: inspection,
                        items: items,
                        defects: inspectionDefects,
                        photos: inspectionPhotos,
                        aiService: aiService,
                        context: modelContext,
                        pdfService: PDFReportService(),
                        businessName: businessName,
                        businessDetails: businessDetails,
                        reportBranding: reportBranding
                    )
                }
            } label: {
                if viewModel.isFinalizing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Finalize and Generate PDF", systemImage: "doc.richtext")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.isFinalizing || items.contains { $0.passed == nil })

            if let reportID = viewModel.generatedReportID {
                NavigationLink(value: Route.report(reportID)) {
                    Label("Open Generated Report", systemImage: "doc.text.magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func beginInspection() {
        guard let selectedVehicle else { return }
        guard !isBlockedByInspectionLimit else {
            viewModel.errorMessage = "Upgrade to Pro or Business for unlimited inspections."
            return
        }
        do {
            let inspection = try viewModel.beginInspection(
                vehicle: selectedVehicle,
                driverName: driverName,
                mileage: mileage,
                notes: notes,
                context: modelContext
            )
            currentInspectionID = inspection.id
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private var isBlockedByInspectionLimit: Bool {
        !subscriptions.canCreateInspection(currentMonthCount: currentMonthInspectionCount)
    }

    private var currentMonthInspectionCount: Int {
        let monthKey = FleetFormatters.monthKey(for: Date())
        return inspections.filter { FleetFormatters.monthKey(for: $0.date) == monthKey }.count
    }
}

private struct InspectionHeaderEditor: View {
    @Bindable var inspection: VehicleInspection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inspection Details")
                .font(.title3.weight(.semibold))
            TextField("Driver name", text: $inspection.driverName)
                .textFieldStyle(.roundedBorder)
            Stepper("Mileage: \(inspection.mileage)", value: $inspection.mileage, in: 0...2_000_000, step: 100)
            TextEditor(text: $inspection.notes)
                .frame(minHeight: 90)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}
