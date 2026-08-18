import SwiftUI

struct ThemePickerView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(AppTheme.allCases.enumerated()), id: \.element.id) { index, theme in
                    if index > 0 {
                        HairlineDivider()
                    }
                    Button {
                        model.theme = theme
                    } label: {
                        HStack(spacing: 12) {
                            Text(theme.name)
                                .font(.body)
                                .foregroundStyle(Color(.label))
                            Spacer(minLength: 0)
                            if model.theme == theme {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Text("Світла або темна тема застосунку. «Системна» повторює налаштування iOS.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 9)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Тема")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ThemePickerView()
            .environment(AppModel.shared)
    }
}
