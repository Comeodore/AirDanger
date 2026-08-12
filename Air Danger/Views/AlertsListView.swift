import SwiftUI

extension ThreatAlert {
    var typeName: String {
        switch type {
        case "ballistic": "Балістика"
        case "irbm": "МБР"
        default: "Загроза"
        }
    }

    var isInbound: Bool { severity == "inbound" }

    var channelName: String {
        switch channel {
        case "kyiv_nebo": "Київське небо"
        case "war_monitor": "monitor"
        default: "@\(channel)"
        }
    }

    var displayText: String {
        let collapsed = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return String(collapsed.drop { !$0.isLetter && !$0.isNumber })
    }

    var title: String {
        isInbound ? "\(typeName) — підтверджений пуск" : "\(typeName) — попередження"
    }

    var iconName: String {
        isInbound ? "speaker.wave.3.fill" : "bell.and.waves.left.and.right"
    }

    var tint: Color {
        isInbound ? .red : Palette.amberIcon
    }
}

struct AlertRow: View {
    let alert: ThreatAlert
    let now: Date
    var textLineLimit: Int? = 3

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(alert.tint.opacity(0.16))
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: alert.iconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(alert.tint)
                }
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(alert.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.label))
                    Spacer(minLength: 0)
                    Text(KyivTime.label(for: alert.ts, now: now))
                        .font(.caption)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                Text(alert.displayText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(textLineLimit)
                Text(alert.channelName)
                    .font(.caption)
                    .foregroundStyle(Color(.tertiaryLabel))
                    .padding(.top, 2)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
}

struct AlertsListView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            switch model.alertsFeed {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .unavailable:
                ContentUnavailableView(
                    "Стрічка недоступна",
                    systemImage: "wifi.slash",
                    description: Text("Не вдалося завантажити останні загрози. Потягніть униз, щоб спробувати ще раз.")
                )
            case .loaded(let alerts) where alerts.isEmpty:
                ContentUnavailableView(
                    "Останнім часом загроз не було",
                    systemImage: "checkmark.shield",
                    description: Text("Щойно моніторингові канали повідомлять про загрозу для Києва, вона з’явиться тут.")
                )
            case .loaded(let alerts):
                TimelineView(.everyMinute) { context in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(alerts.enumerated()), id: \.element.id) { index, alert in
                                if index > 0 {
                                    HairlineDivider()
                                }
                                AlertRow(alert: alert, now: context.date, textLineLimit: nil)
                            }
                        }
                        .background(
                            Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .refreshable { await model.refreshAlerts() }
        .navigationTitle("Останні загрози")
        .task {
            if model.alertsFeed == .loading {
                await model.refreshAlerts()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlertsListView()
            .environment(AppModel.shared)
    }
}
