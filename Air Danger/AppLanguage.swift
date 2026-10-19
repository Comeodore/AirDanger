import Foundation

nonisolated enum AppLanguage: String {
    case en
    case uk

    static let current: AppLanguage = {
        let preferred = Locale.preferredLanguages.first.map(Locale.init(identifier:))
        return preferred?.language.languageCode == .english ? .en : .uk
    }()

    static let bundle: Bundle = Bundle.main.path(forResource: current.rawValue, ofType: "lproj")
        .flatMap(Bundle.init(path:)) ?? .main

    var locale: Locale {
        switch self {
        case .en: Locale(identifier: "en")
        default: Locale(identifier: "uk_UA")
        }
    }
}

nonisolated func tr(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: AppLanguage.bundle, locale: AppLanguage.current.locale)
}
