import AVFoundation
import SwiftUI

struct SoundPickerView: View {
    @Environment(AppModel.self) private var model

    @State private var player: AVAudioPlayer?

    var body: some View {
        ScrollView {
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

            Text("Звук лунає при підтвердженому пуску та в тестовому сповіщенні. Торкніться, щоб прослухати.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 9)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Звук сигналу")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func preview(_ file: String) {
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
