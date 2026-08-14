import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var model = model
        TabView(selection: $model.selectedTab) {
            NavigationStack { AlertsListView() }
                .tabItem { Label("Загрози", systemImage: "exclamationmark.triangle") }
                .tag(AppModel.Tab.threats)
            NavigationStack { SettingsView() }
                .tabItem { Label("Налаштування", systemImage: "gearshape") }
                .tag(AppModel.Tab.settings)
        }
        .task(id: "\(scenePhase)-\(model.onboarded)") {
            guard scenePhase == .active, model.onboarded else { return }
            await model.refreshNotificationStatus()
            await model.syncPrefs()
            while !Task.isCancelled {
                await model.refreshAlerts()
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AppModel.shared)
}
