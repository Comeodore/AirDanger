import Foundation

enum KyivTime {
    static let locale = Locale(identifier: "uk_UA")
    static let zone = TimeZone(identifier: "Europe/Kyiv") ?? .current

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.timeZone = zone
        return calendar
    }()

    private static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .short
        return formatter
    }()

    private static func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = zone
        formatter.dateFormat = format
        return formatter
    }

    private static let clock = formatter("HH:mm")
    private static let dayOfMonth = formatter("d MMMM")
    private static let dayWithWeekday = formatter("EEEE, d MMMM")
    private static let dayWithYear = formatter("d MMMM yyyy")

    static func rowLabel(for date: Date, now: Date = .now) -> String {
        let age = now.timeIntervalSince(date)
        if age < 60 {
            return "щойно"
        }
        if age < 3600 {
            return relative.localizedString(for: date, relativeTo: now)
        }
        return clock.string(from: date)
    }

    static func day(of date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func sectionTitle(for day: Date, now: Date = .now) -> String {
        let today = calendar.startOfDay(for: now)
        if day == today {
            return "Сьогодні"
        }
        if day == calendar.date(byAdding: .day, value: -1, to: today) {
            return "Вчора"
        }
        let daysBack = calendar.dateComponents([.day], from: day, to: today).day ?? 0
        if daysBack < 7 {
            return dayWithWeekday.string(from: day)
        }
        if calendar.component(.year, from: day) != calendar.component(.year, from: today) {
            return dayWithYear.string(from: day)
        }
        return dayOfMonth.string(from: day)
    }
}
