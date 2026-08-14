import ActivityKit
import SwiftUI
import WidgetKit

private let threatsURL = URL(string: "airdanger://threats")!

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
        isClear ? "checkmark.shield.fill" : "exclamationmark.triangle.fill"
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

    var summary: String {
        if isClear {
            let minutes = max(1, Int((Date.now.timeIntervalSince1970 - startedAt) / 60))
            return "Тривало \(minutes) хв · \(countLabel)"
        }
        guard let lastAt else {
            return countLabel
        }
        let clock = kyivClock.string(from: Date(timeIntervalSince1970: lastAt))
        return "\(countLabel) · останній \(clock)"
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

private struct AppShieldMark: View {
    var body: some View {
        ZStack {
            ShieldShape(rightHalfOnly: false)
                .fill(Color(red: 0.04, green: 0.52, blue: 1.0))
            ShieldShape(rightHalfOnly: true)
                .fill(Color(red: 0.03, green: 0.41, blue: 0.8))
        }
        .aspectRatio(24 / 28, contentMode: .fit)
    }
}

private struct ShieldShape: Shape {
    let rightHalfOnly: Bool

    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 24
        let sy = rect.height / 28
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }

        var path = Path()
        path.move(to: p(12, 1.2))
        path.addLine(to: p(22, 5.1))
        path.addLine(to: p(22, 13.5))
        path.addCurve(to: p(12, 26.8), control1: p(22, 20.1), control2: p(17.7, 24.8))

        if !rightHalfOnly {
            path.addCurve(to: p(2, 13.5), control1: p(6.3, 24.8), control2: p(2, 20.1))
            path.addLine(to: p(2, 5.1))
        }

        path.closeSubpath()
        return path
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
            Rectangle()
                .fill(.white.opacity(0.14))
                .frame(height: 0.5)
            Text(state.summary)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .activityBackgroundTint(Color(red: 0.11, green: 0.11, blue: 0.12).opacity(0.93))
        .activitySystemActionForegroundColor(.white)
        .widgetURL(threatsURL)
    }
}

struct ThreatActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ThreatActivityAttributes.self) { context in
            ThreatLockScreenView(state: context.state)
        } dynamicIsland: { context in
            let state = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    HStack(spacing: 11) {
                        ThreatBadge(state: state, size: 32)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(state.title)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text(state.displayText)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.72))
                                .lineLimit(2)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .widgetURL(threatsURL)
                }
            } compactLeading: {
                AppShieldMark()
                    .frame(height: 18)
                    .widgetURL(threatsURL)
            } compactTrailing: {
                Image(systemName: state.iconName)
                    .foregroundStyle(state.tint)
                    .widgetURL(threatsURL)
            } minimal: {
                Image(systemName: state.iconName)
                    .foregroundStyle(state.tint)
                    .widgetURL(threatsURL)
            }
            .keylineTint(state.tint)
        }
    }
}
