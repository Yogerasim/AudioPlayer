import SwiftUI

struct ContentView: View {
    @StateObject private var audio = AudioPlayer()

    let tracks: [Track] = [
        Track(
            title: "Track One",
            artist: "Artist A",
            url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!
        ),
        Track(
            title: "Track Two",
            artist: "Artist B",
            url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3")!
        ),
        Track(
            title: "Track Three",
            artist: "Artist C",
            url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3")!
        )
    ]

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Current track info
            VStack(spacing: 4) {
                if audio.isBuffering {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 3)
                        .shimmer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 14)
                        .shimmer()
                } else if let track = audio.currentTrack {
                    Text(track.title)
                        .font(.title2).bold()

                    Text(track.artist)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)

            // MARK: - Slider
            if audio.duration > 0 {
                Slider(value: Binding(
                    get: { audio.currentTime },
                    set: { audio.seek(to: $0) }
                ), in: 0...audio.duration)
            }

            HStack {
                Text(format(audio.currentTime))
                Spacer()
                Text(format(audio.duration))
            }
            .font(.caption)
            .foregroundColor(.secondary)

            // MARK: - Controls
            HStack(spacing: 40) {
                Button {
                    audio.previous()
                } label: {
                    Image(systemName: "backward.fill").font(.title)
                }

                Button {
                    audio.isPlaying ? audio.pause() : audio.play()
                } label: {
                    Image(systemName: audio.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }

                Button {
                    audio.next()
                } label: {
                    Image(systemName: "forward.fill").font(.title)
                }
            }
            .padding(.top, 12)

            Spacer()
        }
        .padding()
        .onAppear {
            audio.loadPlaylist(tracks)
        }
    }

    func format(_ t: Double) -> String {
        guard t.isFinite else { return "0:00" }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}
#Preview {
    ContentView()
}
