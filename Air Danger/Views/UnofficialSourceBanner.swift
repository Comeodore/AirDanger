import SwiftUI

struct UnofficialSourceBanner: View {
    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Palette.amberIcon)

            VStack(alignment: .leading, spacing: 2) {
                Text("Неофіційне джерело")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.amberTitle)
                Text("Завжди реагуйте на офіційну повітряну тривогу та прямуйте в укриття")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 13)
        .padding(.bottom, 14)
        .background(
            Palette.amberFill,
            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
        )
    }
}

#Preview {
    UnofficialSourceBanner()
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
}
