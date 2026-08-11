import SwiftUI

struct MainView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase

    private var settingsURL: URL {
        URL(string: UIApplication.openNotificationSettingsURLString)!
    }

    private var statusColor: Color {
        model.notificationsEnabled ? .green : .red
    }

    var body: some View {
        VStack(spacing: 12) {
            statusCard
            NotificationLogicCard()
            UnofficialSourceBanner()
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .animation(.default, value: model.notificationsEnabled)
        .task(id: "\(scenePhase)-\(model.onboarded)") {
            guard scenePhase == .active, model.onboarded else { return }
            await model.refreshNotificationStatus()
        }
    }

    private var statusCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                bellBadge
                Text(model.notificationsEnabled ? "Сповіщення увімкнені" : "Сповіщення вимкнені")
                    .font(.headline)
                    .foregroundStyle(Color(.label))
                Spacer(minLength: 0)
                PulsingDot(color: statusColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)

            Link(destination: settingsURL) {
                HStack(spacing: 12) {
                    Text("Налаштування сповіщень")
                        .font(.body)
                        .foregroundStyle(Color.accentColor)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 48)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
        )
    }

    private var bellBadge: some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(statusColor.opacity(0.16))
            .frame(width: 30, height: 30)
            .overlay {
                Image(systemName: model.notificationsEnabled ? "bell" : "bell.slash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(statusColor)
            }
    }
}

private struct PulsingDot: View {
    let color: Color

    @State private var dimmed = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .opacity(dimmed ? 0.4 : 1)
            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: dimmed)
            .onAppear { dimmed = true }
    }
}
