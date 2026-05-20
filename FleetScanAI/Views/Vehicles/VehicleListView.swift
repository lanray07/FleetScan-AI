import SwiftData
import SwiftUI

struct VehicleListView: View {
    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]
    @State private var searchText = ""

    var filteredVehicles: [Vehicle] {
        guard !searchText.isEmpty else { return vehicles }
        return vehicles.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.registrationNumber.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredVehicles.isEmpty {
                    EmptyStateView(title: "No vehicles", message: "Add vans, trucks, trailers, cars, and other fleet assets before starting checks.", systemImage: "box.truck")
                        .padding(.top, 24)
                } else {
                    ForEach(filteredVehicles) { vehicle in
                        NavigationLink(value: Route.vehicle(vehicle.id)) {
                            VehicleCard(vehicle: vehicle)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Vehicles")
        .searchable(text: $searchText, prompt: "Search vehicles")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.editVehicle(nil)) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add vehicle")
            }
        }
    }
}
