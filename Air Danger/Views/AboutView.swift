import SwiftUI

struct AboutView: View {
    private var version: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "Версія \(short) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header
                section("Як це працює") {
                    textCard("Air Danger цілодобово відстежує повідомлення публічних Telegram-каналів, що моніторять повітряну обстановку. Щойно з’являється повідомлення про балістичну загрозу для Києва, застосунок надсилає push-сповіщення — зазвичай упродовж кількох секунд.")
                }
                section("Важливо") {
                    textCard("Сповіщення можуть запізнюватися або не надходити — не покладайтеся на застосунок як на єдине джерело інформації про повітряну загрозу.")
                }
                section("Зв’язок") {
                    linksCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Про застосунок")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            ShieldMark()
                .frame(width: 58, height: 67)
            VStack(spacing: 2) {
                Text("Air Danger")
                    .font(.title2.bold())
                    .foregroundStyle(Color(.label))
                Text(version)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 10)
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.leading, 16)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private var linksCard: some View {
        VStack(spacing: 0) {
            linkRow("Політика конфіденційності", url: "https://airdanger.comeodore.services/privacy")
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
            linkRow("Підтримка", url: "https://airdanger.comeodore.services/support")
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
        )
    }

    private func linkRow(_ title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color.accentColor)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
