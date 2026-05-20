import Foundation
import Observation
import StoreKit
import UIKit

@MainActor
@Observable
final class SubscriptionStore {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?
    var plan: SubscriptionPlan
    var isActive: Bool
    var renewsAt: Date?

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        let rawPlan = UserDefaults.standard.string(forKey: "subscriptionPlan") ?? SubscriptionPlan.free.rawValue
        plan = SubscriptionPlan(rawValue: rawPlan) ?? .free
        isActive = UserDefaults.standard.bool(forKey: "subscriptionIsActive")
        renewsAt = UserDefaults.standard.object(forKey: "subscriptionRenewsAt") as? Date
        updatesTask = observeTransactionUpdates()
    }

    var statusText: String {
        isActive ? "\(plan.displayName) active" : "Free plan"
    }

    var canUseAIDefectScanning: Bool {
        isActive && plan != .free
    }

    var canExportPDF: Bool {
        isActive && plan != .free
    }

    var canUseFleetDashboard: Bool {
        plan == .businessMonthly
    }

    var vehicleLimit: Int? {
        switch plan {
        case .free:
            2
        case .proMonthly, .proYearly:
            10
        case .businessMonthly:
            nil
        }
    }

    var monthlyInspectionLimit: Int? {
        plan == .free ? 5 : nil
    }

    func canAddVehicle(currentCount: Int) -> Bool {
        guard let vehicleLimit else { return true }
        return currentCount < vehicleLimit
    }

    func canCreateInspection(currentMonthCount: Int) -> Bool {
        guard let monthlyInspectionLimit else { return true }
        return currentMonthCount < monthlyInspectionLimit
    }

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            products = try await Product.products(for: AppConstants.Store.productIDs).sorted { $0.displayPrice < $1.displayPrice }
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            apply(productID: transaction.productID, renewsAt: transaction.expirationDate)
            await transaction.finish()
            await refreshEntitlements()
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
    }

    func activateMock(plan selectedPlan: SubscriptionPlan) {
        plan = selectedPlan
        isActive = selectedPlan != .free
        renewsAt = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        persist()
    }

    func refreshEntitlements() async {
        var activeProductIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            activeProductIDs.insert(transaction.productID)
            apply(productID: transaction.productID, renewsAt: transaction.expirationDate)
        }

        purchasedProductIDs = activeProductIDs
        if activeProductIDs.isEmpty, plan != .free, !isActive {
            activateMock(plan: .free)
        }
    }

    func openManageSubscriptions() async {
        guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            return
        }
        try? await AppStore.showManageSubscriptions(in: scene)
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                guard case .verified(let transaction) = result else { continue }
                await self.apply(productID: transaction.productID, renewsAt: transaction.expirationDate)
                await transaction.finish()
            }
        }
    }

    private func apply(productID: String, renewsAt date: Date?) {
        switch productID {
        case AppConstants.Store.productProMonthly:
            plan = .proMonthly
        case AppConstants.Store.productProYearly:
            plan = .proYearly
        case AppConstants.Store.productBusinessMonthly:
            plan = .businessMonthly
        default:
            plan = .free
        }
        isActive = plan != .free
        renewsAt = date
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(plan.rawValue, forKey: "subscriptionPlan")
        UserDefaults.standard.set(isActive, forKey: "subscriptionIsActive")
        UserDefaults.standard.set(renewsAt, forKey: "subscriptionRenewsAt")
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "StoreKit transaction verification failed."
    }
}
