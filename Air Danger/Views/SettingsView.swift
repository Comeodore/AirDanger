import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model

    @State private var testSent = false

    private var settingsURL: URL {
        URL(string: UIApplication.openNotificationSettingsURLString)!
    }

    private var statusColor: Color {
        model.notificationsEnabled ? .green : .red
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                UnofficialSourceBanner()
                statusCard
                infoCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .animation(.default, value: model.notificationsEnabled)
        .navigationTitle("Налаштування")
        .navigationBarTitleDisplayMode(.inline)
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

            divider

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

            divider

            Button {
                guard !testSent else { return }
                Task {
                    await model.sendTestNotification()
                    withAnimation { testSent = true }
                    try? await Task.sleep(for: .seconds(2.5))
                    withAnimation { testSent = false }
                }
            } label: {
                HStack(spacing: 12) {
                    Text("Тестове сповіщення")
                        .font(.body)
                        .foregroundStyle(Color.accentColor)
                    Spacer(minLength: 0)
                    Image(systemName: testSent ? "checkmark.circle.fill" : "bell.badge")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(testSent ? Color.green : Color(.tertiaryLabel))
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

    private var infoCard: some View {
        VStack(spacing: 0) {
            navRow("Як це працює") { HowItWorksView() }
            divider
            navRow("Про застосунок") { AboutView() }
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
        )
    }

    private func navRow(
        _ title: String, @ViewBuilder destination: @escaping () -> some View
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color(.label))
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

    private var divider: some View {
        HairlineDivider()
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

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .phaseAnimator([1.0, 0.4]) { dot, phase in
                dot.opacity(phase)
            } animation: { _ in
                .easeInOut(duration: 1.6)
            }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppModel.shared)
    }
}
