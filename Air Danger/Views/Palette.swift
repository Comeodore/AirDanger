import SwiftUI
import UIKit

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var name: String {
        switch self {
        case .system: "Системна"
        case .light: "Світла"
        case .dark: "Темна"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct HairlineDivider: View {
    @Environment(\.displayScale) private var scale

    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 1 / max(scale, 1))
    }
}

enum Palette {
    static let amberIcon = adaptive(dark: Color(hex: 0xFF9F0A), light: Color(hex: 0xC97A00))
    static let amberTitle = adaptive(dark: Color(hex: 0xFFB340), light: Color(hex: 0x8F5100))
    static let amberFill = adaptive(
        dark: Color(hex: 0xFF9F0A, opacity: 0.11),
        light: Color(hex: 0xFF9F0A, opacity: 0.13)
    )
    static let blueDeep = adaptive(dark: Color(hex: 0x0768CC), light: Color(hex: 0x0062CC))

    static let cardRadius: CGFloat = 22
    static let buttonRadius: CGFloat = 16

    private static func adaptive(dark: Color, light: Color) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
