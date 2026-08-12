import Foundation

enum KyivTime {
    static let locale = Locale(identifier: "uk_UA")
    static let zone = TimeZone(identifier: "Europe/Kyiv") ?? .current

    private static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .short
        return formatter
    }()

    private static let absolute: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = zone
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter
    }()

    static func label(for date: Date, now: Date = .now) -> String {
        let age = now.timeIntervalSince(date)
        if age < 60 {
            return "щойно"
        }
        if age < 24 * 3600 {
            return relative.localizedString(for: date, relativeTo: now)
        }
        return absolute.string(from: date)
    }
}
