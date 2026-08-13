import SwiftUI

struct HowItWorksView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                textCard("Air Danger цілодобово відстежує повідомлення публічних моніторингових Telegram-каналів. Система самостійно розпізнає тип загрози — балістика чи МБР, оцінює рівень — попередження чи підтверджений пуск, відсіює повідомлення, що не стосуються Києва, та об’єднує сигнали у хвилі. Сповіщення надходить лише тоді, коли загроза стосується Києва — зазвичай упродовж кількох секунд.")
                NotificationLogicCard()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Як це працює")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func textCard(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Color(.label))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
            )
    }
}

#Preview {
    NavigationStack {
        HowItWorksView()
    }
}
