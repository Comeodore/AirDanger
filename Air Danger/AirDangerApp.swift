import SwiftUI

@main
struct AirDangerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var model = AppModel.shared
    @AppStorage("onboarded") private var onboarded = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .fullScreenCover(isPresented: .constant(!onboarded)) {
                    OnboardingView()
                        .environment(model)
                }
                .task {
                    guard onboarded else { return }
                    UIApplication.shared.registerForRemoteNotifications()
                }
        }
    }
}
