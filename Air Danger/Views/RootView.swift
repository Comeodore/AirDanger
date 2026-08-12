import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            MainView()
                .tabItem { Label("Сповіщення", systemImage: "bell.badge") }
            NavigationStack { AlertsListView() }
                .tabItem { Label("Загрози", systemImage: "exclamationmark.triangle") }
            NavigationStack { AboutView() }
                .tabItem { Label("Інфо", systemImage: "info.circle") }
        }
        .task(id: "\(scenePhase)-\(model.onboarded)") {
            guard scenePhase == .active, model.onboarded else { return }
            async let status: Void = model.refreshNotificationStatus()
            async let alerts: Void = model.refreshAlerts()
            _ = await (status, alerts)
        }
    }
}

#Preview {
    RootView()
        .environment(AppModel.shared)
}
