import ActivityKit
import SwiftUI
import WidgetKit

private let kyivClock: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "uk_UA")
    formatter.timeZone = TimeZone(identifier: "Europe/Kyiv") ?? .current
    formatter.dateFormat = "HH:mm"
    return formatter
}()

extension ThreatActivityAttributes.ContentState {
    var isClear: Bool { state == "clear" }

    var isInbound: Bool { severity == "inbound" }

    var started: Date { Date(timeIntervalSince1970: startedAt) }

    var escalated: Date? { escalatedAt.map(Date.init(timeIntervalSince1970:)) }

    var typeName: String { type == "irbm" ? "МБР" : "Балістика" }

    var title: String {
        if isClear {
            return "Відбій"
        }
        return isInbound ? "\(typeName) — підтверджений пуск" : "\(typeName) — попередження"
    }

    var displayText: String {
        let collapsed = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return String(collapsed.drop { !$0.isLetter && !$0.isNumber })
    }

    var iconName: String {
        isClear ? "checkmark.shield" : "exclamationmark.triangle.fill"
    }

    var tint: Color {
        if isClear {
            return Color(red: 0.19, green: 0.82, blue: 0.35)
        }
        if isInbound {
            return Color(red: 1.0, green: 0.27, blue: 0.23)
        }
        return Color(red: 1.0, green: 0.62, blue: 0.04)
    }

    var countLabel: String {
        let mod10 = count % 10
        let mod100 = count % 100
        let word: String
        if mod10 == 1 && mod100 != 11 {
            word = "сигнал"
        } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            word = "сигнали"
        } else {
            word = "сигналів"
        }
        return "\(count) \(word)"
    }

    var timeline: String {
        if isClear {
            let minutes = max(1, Int((Date.now.timeIntervalSince1970 - startedAt) / 60))
            return "Тривало \(minutes) хв · \(countLabel)"
        }
        if let escalated, escalatedAt != startedAt {
            return "Попередження \(kyivClock.string(from: started)) → Пуск \(kyivClock.string(from: escalated)) · \(countLabel)"
        }
        let label = isInbound ? "Пуск" : "Попередження"
        return "\(label) \(kyivClock.string(from: started)) · \(countLabel)"
    }
}

private struct ThreatBadge: View {
    let state: ThreatActivityAttributes.ContentState
    var size: CGFloat = 34

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(state.tint.opacity(0.2))
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: state.iconName)
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundStyle(state.tint)
            }
    }
}

private struct ThreatLockScreenView: View {
    let state: ThreatActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 11) {
                ThreatBadge(state: state)
                VStack(alignment: .leading, spacing: 1) {
                    Text(state.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(state.displayText)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(2)
                }
                .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            HairlineRule()
            Text(state.timeline)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .activityBackgroundTint(Color(red: 0.11, green: 0.11, blue: 0.12).opacity(0.93))
        .activitySystemActionForegroundColor(.white)
    }
}

private struct HairlineRule: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.14))
            .frame(height: 0.5)
    }
}

struct ThreatActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ThreatActivityAttributes.self) { context in
            ThreatLockScreenView(state: context.state)
        } dynamicIsland: { context in
            let state = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ThreatBadge(state: state, size: 30)
                        .padding(.top, 2)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(state.title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(state.displayText)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.72))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(state.timeline)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            } compactLeading: {
                Image(systemName: state.iconName)
                    .foregroundStyle(state.tint)
            } compactTrailing: {
                EmptyView()
            } minimal: {
                Image(systemName: state.iconName)
                    .foregroundStyle(state.tint)
            }
            .keylineTint(state.tint)
        }
    }
}
