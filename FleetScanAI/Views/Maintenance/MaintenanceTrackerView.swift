import SwiftData
import SwiftUI

struct MaintenanceTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notifications

    @Query(sort: \MaintenanceReminder.dueDate) private var reminders: [MaintenanceReminder]
    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

    @State private var showingAddReminder = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Label("Add Reminder", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        syncVehicleDates()
                    } label: {
                        Label("Sync Dates", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .buttonStyle(.bordered)
                }

                if reminders.isEmpty {
                    EmptyStateView(title: "No reminders", message: "Track MOT, insurance, service, tyres, brakes, oil changes, and inspection due dates.", systemImage: "bell.badge")
                } else {
                    ForEach(reminders) { reminder in
                        HStack(alignment: .center, spacing: 12) {
                            MaintenanceReminderCard(reminder: reminder, vehicleName: vehicleName(for: reminder.vehicleId))
                            Button {
                                toggle(reminder)
                            } label: {
                                Image(systemName: reminder.completed ? "arrow.uturn.backward.circle" : "checkmark.circle")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Maintenance")
        .sheet(isPresented: $showingAddReminder) {
            MaintenanceEditorSheet(vehicles: vehicles) { reminder in
                modelContext.insert(reminder)
                try? modelContext.save()
                schedule(reminder)
            }
        }
        .task {
            await notifications.refreshAuthorizationStatus()
        }
    }

    private func toggle(_ reminder: MaintenanceReminder) {
        reminder.completed.toggle()
        if reminder.completed {
            notifications.cancel(reminder: reminder)
        } else {
            schedule(reminder)
        }
        try? modelContext.save()
    }

    private func syncVehicleDates() {
        for vehicle in vehicles {
            insertReminderIfNeeded(vehicle: vehicle, title: "MOT expiry", category: .motExpiry, dueDate: vehicle.motExpiryDate)
            insertReminderIfNeeded(vehicle: vehicle, title: "Insurance renewal", category: .insuranceRenewal, dueDate: vehicle.insuranceExpiryDate)
            insertReminderIfNeeded(vehicle: vehicle, title: "Service due", category: .serviceDate, dueDate: vehicle.serviceDueDate)
            insertReminderIfNeeded(vehicle: vehicle, title: "Daily inspection due", category: .inspectionDue, dueDate: Date())
        }
        try? modelContext.save()
    }

    private func insertReminderIfNeeded(vehicle: Vehicle, title: String, category: MaintenanceCategory, dueDate: Date?) {
        guard let dueDate else { return }
        let exists = reminders.contains {
            $0.vehicleId == vehicle.id &&
            $0.category == category &&
            Calendar.current.isDate($0.dueDate, inSameDayAs: dueDate)
        }
        guard !exists else { return }
        let reminder = MaintenanceReminder(vehicleId: vehicle.id, title: title, category: category, dueDate: dueDate)
        modelContext.insert(reminder)
        schedule(reminder)
    }

    private func schedule(_ reminder: MaintenanceReminder) {
        let name = vehicleName(for: reminder.vehicleId)
        Task {
            try? await notifications.schedule(reminder: reminder, vehicleName: name)
        }
    }

    private func vehicleName(for id: UUID) -> String {
        vehicles.first { $0.id == id }?.name ?? "Unknown vehicle"
    }
}

private struct MaintenanceEditorSheet: View {
    let vehicles: [Vehicle]
    let onSave: (MaintenanceReminder) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedVehicleID: UUID?
    @State private var title = ""
    @State private var category: MaintenanceCategory = .serviceDate
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder") {
                    Picker("Vehicle", selection: $selectedVehicleID) {
                        ForEach(vehicles) { vehicle in
                            Text("\(vehicle.name) - \(vehicle.registrationNumber)").tag(Optional(vehicle.id))
                        }
                    }
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(MaintenanceCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let selectedVehicleID else { return }
                        onSave(MaintenanceReminder(
                            vehicleId: selectedVehicleID,
                            title: title.isEmpty ? category.displayName : title,
                            category: category,
                            dueDate: dueDate
                        ))
                        dismiss()
                    }
                    .disabled(selectedVehicleID == nil)
                }
            }
            .onAppear {
                selectedVehicleID = selectedVehicleID ?? vehicles.first?.id
            }
        }
    }
}
