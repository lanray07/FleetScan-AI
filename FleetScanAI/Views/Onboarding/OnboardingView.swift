import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @AppStorage("selectedUserType") private var selectedUserTypeRaw = UserType.driver.rawValue
    @State private var selectedUserType: UserType = .driver
    @State private var acceptedDisclaimer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(AppConstants.appName)
                            .font(.largeTitle.weight(.bold))
                        Text("AI-assisted inspections, defect reports, maintenance records, and fleet visibility for busy vehicle teams.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select your role")
                            .font(.title3.weight(.semibold))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                            ForEach(UserType.allCases) { userType in
                                Button {
                                    selectedUserType = userType
                                } label: {
                                    HStack {
                                        Text(userType.displayName)
                                            .font(.subheadline.weight(.semibold))
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        if selectedUserType == userType {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                                    .padding()
                                    .background(
                                        selectedUserType == userType ? Color.blue.opacity(0.12) : Color(.secondarySystemGroupedBackground),
                                        in: RoundedRectangle(cornerRadius: 8)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Safety disclaimer")
                            .font(.title3.weight(.semibold))
                        ForEach(AppConstants.disclaimers, id: \.self) { disclaimer in
                            Label(disclaimer, systemImage: "checkmark.shield")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }

                        Toggle("I understand and will review AI suggestions before acting.", isOn: $acceptedDisclaimer)
                            .font(.subheadline.weight(.semibold))
                            .toggleStyle(.switch)
                            .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))

                    Button {
                        selectedUserTypeRaw = selectedUserType.rawValue
                        onComplete()
                    } label: {
                        Label("Start using FleetScan AI", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!acceptedDisclaimer)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Welcome")
            .onAppear {
                selectedUserType = UserType(rawValue: selectedUserTypeRaw) ?? .driver
            }
        }
    }
}
