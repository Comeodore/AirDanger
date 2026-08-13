import SwiftUI

extension ThreatAlert {
    var typeName: String {
        switch type {
        case "ballistic": "Балістика"
        case "irbm": "МБР"
        case "all_clear": "Відбій"
        default: "Загроза"
        }
    }

    var isInbound: Bool { severity == "inbound" }

    var isAllClear: Bool { type == "all_clear" }

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
        if isAllClear {
            return "Відбій"
        }
        return isInbound ? "\(typeName) — підтверджений пуск" : "\(typeName) — попередження"
    }

    var iconName: String {
        if isAllClear {
            return "checkmark.shield"
        }
        return isInbound ? "speaker.wave.3.fill" : "bell.and.waves.left.and.right"
    }

    var tint: Color {
        if isAllClear {
            return .green
        }
        return isInbound ? .red : Palette.amberIcon
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
                    Text(KyivTime.rowLabel(for: alert.ts, now: now))
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

private struct DaySection: Identifiable {
    let day: Date
    var alerts: [ThreatAlert]
    var id: Date { day }
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
                    "Загроз не зафіксовано",
                    systemImage: "checkmark.shield",
                    description: Text("Щойно моніторингові канали повідомлять про загрозу для Києва, вона з’явиться тут.")
                )
            case .loaded(let alerts):
                TimelineView(.everyMinute) { context in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sections(from: alerts)) { section in
                                sectionHeader(
                                    KyivTime.sectionTitle(for: section.day, now: context.date)
                                )
                                sectionCard(section, now: context.date)
                            }
                            if !model.alertsExhausted {
                                ProgressView()
                                    .padding(.vertical, 16)
                                    .onAppear {
                                        Task { await model.loadMoreAlerts() }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .refreshable { await model.refreshAlerts() }
        .navigationTitle("Загрози")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if model.alertsFeed == .loading {
                await model.refreshAlerts()
            }
        }
    }

    private func sections(from alerts: [ThreatAlert]) -> [DaySection] {
        var result: [DaySection] = []
        for alert in alerts {
            let day = KyivTime.day(of: alert.ts)
            if result.last?.day == day {
                result[result.count - 1].alerts.append(alert)
            } else {
                result.append(DaySection(day: day, alerts: [alert]))
            }
        }
        return result
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            .padding(.bottom, 7)
    }

    private func sectionCard(_ section: DaySection, now: Date) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(section.alerts.enumerated()), id: \.element.id) { index, alert in
                if index > 0 {
                    HairlineDivider()
                }
                Button {
                    model.openChannel(alert.channel)
                } label: {
                    AlertRow(alert: alert, now: now, textLineLimit: nil)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
        )
        .padding(.bottom, 14)
    }
}

#Preview {
    NavigationStack {
        AlertsListView()
            .environment(AppModel.shared)
    }
}
