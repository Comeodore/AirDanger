import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model

    @State private var testSent = false

    private var settingsURL: URL {
        URL(string: UIApplication.openNotificationSettingsURLString)!
    }

    private var version: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "Версія \(short) (\(build))"
    }

    private var criticalMissing: Bool {
        model.notificationsEnabled && !model.criticalAlertsEnabled
    }

    private var statusColor: Color {
        if !model.notificationsEnabled { return .red }
        return model.criticalAlertsEnabled ? .green : Palette.amberIcon
    }

    private var statusIcon: String {
        if !model.notificationsEnabled { return "bell.slash" }
        return model.criticalAlertsEnabled ? "bell.badge" : "bell.badge.slash"
    }

    private var statusTitle: String {
        if !model.notificationsEnabled { return "Сповіщення вимкнені" }
        return model.criticalAlertsEnabled
            ? "Критичні сповіщення увімкнені"
            : "Критичні сповіщення вимкнені"
    }

    private var statusDetail: String? {
        if !model.notificationsEnabled {
            return "Без дозволу застосунок не попередить про пуск"
        }
        return model.criticalAlertsEnabled
            ? "Сигнал про підтверджений пуск лунає навіть у беззвучному режимі"
            : nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                UnofficialSourceBanner()
                statusCard
                prefsCard
                versionLabel
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Налаштування")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                bellBadge
                VStack(alignment: .leading, spacing: 1) {
                    Text(statusTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(criticalMissing ? Palette.amberTitle : Color(.label))
                    if let statusDetail {
                        Text(statusDetail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                PulsingDot(color: statusColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(criticalMissing ? Palette.amberFill : Color.clear)

            divider

            Link(destination: settingsURL) {
                row(title: "Налаштування сповіщень", chevron: true)
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
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous))
    }

    private var prefsCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Попередження про загрозу")
                        .font(.body)
                        .foregroundStyle(Color(.label))
                    Text("Тихі сповіщення про можливу загрозу. Підтверджені пуски надходять завжди")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Toggle("", isOn: Binding(
                    get: { model.warningsEnabled },
                    set: { enabled in Task { await model.setWarnings(enabled) } }
                ))
                .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)

            divider

            NavigationLink {
                SoundPickerView()
            } label: {
                HStack(spacing: 12) {
                    Text("Звук сигналу")
                        .font(.body)
                        .foregroundStyle(Color(.label))
                    Spacer(minLength: 0)
                    Text(AlertSound.name(of: model.alertSound))
                        .font(.body)
                        .foregroundStyle(.secondary)
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

            NavigationLink {
                ThemePickerView()
            } label: {
                HStack(spacing: 12) {
                    Text("Тема")
                        .font(.body)
                        .foregroundStyle(Color(.label))
                    Spacer(minLength: 0)
                    Text(model.theme.name)
                        .font(.body)
                        .foregroundStyle(.secondary)
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

    private var versionLabel: some View {
        Text(version)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }

    private func row(title: String, chevron: Bool) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color.accentColor)
            Spacer(minLength: 0)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }

    private var divider: some View {
        HairlineDivider()
    }

    private var bellBadge: some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(statusColor.opacity(0.16))
            .frame(width: 30, height: 30)
            .overlay {
                Image(systemName: statusIcon)
                    .font(.system(size: 15, weight: .medium))
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
            .geometryGroup()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppModel.shared)
    }
}
