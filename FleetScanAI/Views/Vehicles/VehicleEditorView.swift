import SwiftData
import SwiftUI

struct VehicleEditorView: View {
    let vehicleID: UUID?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionStore.self) private var subscriptions
    @Query private var vehicles: [Vehicle]

    @State private var name = ""
    @State private var registrationNumber = ""
    @State private var vehicleType: VehicleType = .van
    @State private var mileage = 0
    @State private var motExpiryDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var insuranceExpiryDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var serviceDueDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var notes = ""
    @State private var isRoadworthy = true

    private var vehicle: Vehicle? {
        vehicleID.flatMap { id in vehicles.first { $0.id == id } }
    }

    var body: some View {
        Form {
            Section("Vehicle Profile") {
                if vehicleID == nil, !subscriptions.canAddVehicle(currentCount: vehicles.count) {
                    NavigationLink(value: Route.paywall) {
                        UpgradeBanner(
                            title: "Vehicle limit reached",
                            message: "Free supports 2 vehicles. Pro supports 10 vehicles and Business supports unlimited vehicles."
                        )
                    }
                    .buttonStyle(.plain)
                }
                TextField("Vehicle name", text: $name)
                TextField("Registration number", text: $registrationNumber)
                    .textInputAutocapitalization(.characters)
                Picker("Vehicle type", selection: $vehicleType) {
                    ForEach(VehicleType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                Stepper("Mileage: \(mileage)", value: $mileage, in: 0...2_000_000, step: 100)
                Toggle("Roadworthy", isOn: $isRoadworthy)
            }

            Section("Compliance Dates") {
                DatePicker("MOT expiry", selection: $motExpiryDate, displayedComponents: .date)
                DatePicker("Insurance expiry", selection: $insuranceExpiryDate, displayedComponents: .date)
                DatePicker("Service due", selection: $serviceDueDate, displayedComponents: .date)
            }

            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 110)
            }
        }
        .navigationTitle(vehicleID == nil ? "Add Vehicle" : "Edit Vehicle")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isBlockedByVehicleLimit)
            }
        }
        .onAppear(perform: populate)
    }

    private var isBlockedByVehicleLimit: Bool {
        vehicleID == nil && !subscriptions.canAddVehicle(currentCount: vehicles.count)
    }

    private func populate() {
        guard let vehicle else { return }
        name = vehicle.name
        registrationNumber = vehicle.registrationNumber
        vehicleType = vehicle.vehicleType
        mileage = vehicle.mileage
        motExpiryDate = vehicle.motExpiryDate ?? motExpiryDate
        insuranceExpiryDate = vehicle.insuranceExpiryDate ?? insuranceExpiryDate
        serviceDueDate = vehicle.serviceDueDate ?? serviceDueDate
        notes = vehicle.notes
        isRoadworthy = vehicle.isRoadworthy
    }

    private func save() {
        if let vehicle {
            vehicle.name = name
            vehicle.registrationNumber = registrationNumber
            vehicle.vehicleType = vehicleType
            vehicle.mileage = mileage
            vehicle.motExpiryDate = motExpiryDate
            vehicle.insuranceExpiryDate = insuranceExpiryDate
            vehicle.serviceDueDate = serviceDueDate
            vehicle.notes = notes
            vehicle.isRoadworthy = isRoadworthy
        } else {
            modelContext.insert(Vehicle(
                name: name,
                registrationNumber: registrationNumber,
                vehicleType: vehicleType,
                mileage: mileage,
                motExpiryDate: motExpiryDate,
                insuranceExpiryDate: insuranceExpiryDate,
                serviceDueDate: serviceDueDate,
                notes: notes,
                isRoadworthy: isRoadworthy
            ))
        }
        try? modelContext.save()
        dismiss()
    }
}
