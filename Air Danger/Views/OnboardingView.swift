import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 22) {
                ShieldMark()
                    .frame(width: 76, height: 88)

                VStack(spacing: 10) {
                    Text(verbatim: "Air Danger")
                        .font(.largeTitle.bold())
                        .tracking(-1)
                        .foregroundStyle(Color(.label))
                    Text(tr("Розпізнає балістичні загрози для Києва у повідомленнях моніторингових каналів і сповіщає за лічені секунди — коли рахунок іде на хвилини"))
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 310)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 8)
            .padding(.bottom, 24)

            VStack(spacing: 14) {
                UnofficialSourceBanner()

                Button {
                    Task {
                        await model.enableNotifications()
                        model.onboarded = true
                    }
                } label: {
                    Text(tr("Увімкнути сповіщення"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            Color.accentColor,
                            in: RoundedRectangle(cornerRadius: Palette.buttonRadius, style: .continuous)
                        )
                }
                .buttonStyle(.plain)

                Text(tr("Окремо попросимо дозвіл на критичні сповіщення — щоб сигнал про підтверджений пуск пролунав навіть у беззвучному режимі та в «Не турбувати»"))
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .readableColumn(Palette.onboardingWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .interactiveDismissDisabled()
    }
}
