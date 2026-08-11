import SwiftUI

struct NotificationLogicCard: View {
    var body: some View {
        VStack(spacing: 0) {
            row(
                icon: "bell.and.waves.left.and.right",
                tint: Palette.amberIcon,
                title: "Попередження про загрозу",
                detail: "Тихе сповіщення — лише вібрація"
            )
            divider
            row(
                icon: "speaker.wave.3.fill",
                tint: .red,
                title: "Підтверджений пуск",
                detail: "Гучний сигнал — на рівні гучності дзвінка"
            )
            divider
            row(
                icon: "moon.fill",
                tint: .indigo,
                title: "«Не турбувати» і фокусування",
                detail: "Сповіщення надходять за стандартних налаштувань iOS"
            )
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
    }

    private func row(icon: String, tint: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(tint.opacity(0.16))
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(tint)
                }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.label))
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
}

#Preview {
    NotificationLogicCard()
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
}
