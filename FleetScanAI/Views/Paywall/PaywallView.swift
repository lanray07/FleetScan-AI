import StoreKit
import SwiftData
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionStore.self) private var subscriptions
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptionStates: [SubscriptionState]

    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("FleetScan AI Plans")
                        .font(.largeTitle.weight(.bold))
                    Text("Start free, then unlock AI scans, PDF exports, maintenance reminders, fleet dashboards, and custom branding.")
                        .foregroundStyle(.secondary)
                }

                ForEach(SubscriptionPlan.allCases) { plan in
                    PlanCard(
                        plan: plan,
                        isCurrent: subscriptions.plan == plan,
                        product: product(for: plan),
                        isPurchasing: isPurchasing
                    ) {
                        Task { await select(plan: plan) }
                    }
                }

                Text("Pricing and product identifiers are placeholders. Configure App Store Connect products before release.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Subscription")
        .alert("Subscription Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            await subscriptions.loadProducts()
        }
    }

    private func product(for plan: SubscriptionPlan) -> Product? {
        guard let productID = plan.productID else { return nil }
        return subscriptions.products.first { $0.id == productID }
    }

    private func select(plan: SubscriptionPlan) async {
        if plan == .free {
            subscriptions.activateMock(plan: .free)
            upsertSubscriptionState(plan: .free, isActive: false)
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            if let product = product(for: plan) {
                try await subscriptions.purchase(product)
            } else {
                subscriptions.activateMock(plan: plan)
            }
            upsertSubscriptionState(plan: subscriptions.plan, isActive: subscriptions.isActive)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func upsertSubscriptionState(plan: SubscriptionPlan, isActive: Bool) {
        let state = subscriptionStates.first ?? SubscriptionState()
        state.plan = plan
        state.isActive = isActive
        state.renewsAt = subscriptions.renewsAt
        if subscriptionStates.isEmpty {
            modelContext.insert(state)
        }
        try? modelContext.save()
    }
}

private struct PlanCard: View {
    let plan: SubscriptionPlan
    let isCurrent: Bool
    let product: Product?
    let isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.displayName)
                        .font(.title3.weight(.semibold))
                    Text(product?.displayPrice ?? plan.priceText)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                Spacer()
                if isCurrent {
                    Text("Current")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.12), in: Capsule())
                }
            }

            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark.circle")
                    .font(.subheadline)
            }

            actionButton
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var actionButton: some View {
        if plan == .free {
            Button(action: action) {
                buttonLabel
            }
            .buttonStyle(.bordered)
            .disabled(isCurrent || isPurchasing)
        } else {
            Button(action: action) {
                buttonLabel
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCurrent || isPurchasing)
        }
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if isPurchasing {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else {
            Text(isCurrent ? "Selected" : buttonTitle)
                .frame(maxWidth: .infinity)
        }
    }

    private var buttonTitle: String {
        product == nil && plan != .free ? "Activate Mock \(plan.displayName)" : plan == .free ? "Use Free" : "Subscribe"
    }

    private var features: [String] {
        switch plan {
        case .free:
            ["2 vehicles", "5 inspections/month", "Basic defect reports", "FleetScan AI footer"]
        case .proMonthly, .proYearly:
            ["Unlimited inspections", "10 vehicles", "AI defect scanning", "PDF exports", "Maintenance reminders"]
        case .businessMonthly:
            ["Unlimited vehicles", "Fleet manager dashboard", "Advanced reports", "Custom branding", "Multi-driver/team placeholder"]
        }
    }
}
