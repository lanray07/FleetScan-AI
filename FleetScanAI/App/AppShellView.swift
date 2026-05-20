import SwiftUI

struct AppShellView: View {
    @Environment(SubscriptionStore.self) private var subscriptions
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
                    .withAppDestinations()
            }
            .tabItem { AppTab.dashboard.label }
            .tag(AppTab.dashboard)

            NavigationStack {
                VehicleListView()
                    .withAppDestinations()
            }
            .tabItem { AppTab.vehicles.label }
            .tag(AppTab.vehicles)

            NavigationStack {
                DefectsListView()
                    .withAppDestinations()
            }
            .tabItem { AppTab.defects.label }
            .tag(AppTab.defects)

            NavigationStack {
                ReportsCenterView()
                    .withAppDestinations()
            }
            .tabItem { AppTab.reports.label }
            .tag(AppTab.reports)

            NavigationStack {
                SettingsView()
                    .withAppDestinations()
            }
            .tabItem { AppTab.settings.label }
            .tag(AppTab.settings)
        }
        .task {
            await subscriptions.loadProducts()
        }
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                AppShellView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
