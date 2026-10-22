import AVFoundation
import SwiftUI

struct SoundPickerView: View {
    @Environment(AppModel.self) private var model

    @State private var player: AVAudioPlayer?

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(AlertSound.choices.enumerated()), id: \.element.id) { index, sound in
                        if index > 0 {
                            HairlineDivider()
                        }
                        Button {
                            Task { await model.setSound(sound.file) }
                            preview(sound.file)
                        } label: {
                            HStack(spacing: 12) {
                                Text(sound.name)
                                    .font(.body)
                                    .foregroundStyle(Color(.label))
                                Spacer(minLength: 0)
                                if model.alertSound == sound.file {
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

                Text(tr("Звук лунає при підтвердженому пуску та в тестовому сповіщенні. Торкніться, щоб прослухати."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 9)

                volumeCard($model.criticalVolume)
                    .padding(.horizontal, 16)
                    .padding(.top, 18)

                Text(volumeFootnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 9)
                    .padding(.bottom, 16)
            }
            .readableColumn()
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(tr("Звук сигналу"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func volumeCard(_ volume: Binding<Double>) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                Text(tr("Гучність"))
                    .font(.body)
                    .foregroundStyle(Color(.label))
                Spacer(minLength: 0)
                Text(volumeLabel)
                    .font(.body)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.tertiaryLabel))
                Slider(
                    value: volume,
                    in: AppModel.minCriticalVolume...AppModel.defaultCriticalVolume
                ) { editing in
                    guard !editing else { return }
                    Task { await model.commitCriticalVolume() }
                    preview(model.alertSound)
                }
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .disabled(!model.criticalAlertsEnabled)
            .opacity(model.criticalAlertsEnabled ? 1 : 0.4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 11)
        .padding(.bottom, 9)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Palette.cardRadius, style: .continuous)
        )
    }

    private var vibrates: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    private var volumeLabel: String {
        guard model.criticalAlertsEnabled else { return tr("недоступна") }
        let percent = Int((model.criticalVolume * 100).rounded())
        guard percent == 0 else { return "\(percent)%" }
        return vibrates ? tr("лише вібрація") : tr("без звуку")
    }

    private var volumeFootnote: String {
        guard model.criticalAlertsEnabled else {
            return tr("Гучністю можна керувати лише для критичних сповіщень — увімкніть їх у налаштуваннях сповіщень iOS. Зараз прослуховування йде на гучності медіа.")
        }
        return vibrates
            ? tr("Гучність критичного сповіщення про підтверджений пуск. Не залежить від гучності дзвінка, медіа та беззвучного режиму — прослуховування звучить рівно так, як прозвучить сигнал. На нулі сповіщення надійде без звуку, лише вібрацією.")
            : tr("Гучність критичного сповіщення про підтверджений пуск. Не залежить від гучності медіа та беззвучного режиму — прослуховування звучить рівно так, як прозвучить сигнал. На нулі сповіщення надійде без звуку.")
    }

    private func preview(_ file: String) {
        Task {
            guard await model.previewSound(file) == false else { return }
            playInApp(file)
        }
    }

    private func playInApp(_ file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}

#Preview {
    NavigationStack {
        SoundPickerView()
            .environment(AppModel.shared)
    }
}
