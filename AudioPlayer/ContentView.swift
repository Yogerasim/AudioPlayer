import SwiftUI

struct ContentView: View {
    @StateObject private var audio = AudioPlayer()

    let tracks: [Track] = [
        Track(
            title: "Epic Journey",
            artist: "John Smith",
            url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!
        ),
        Track(
            title: "Morning Breeze",
            artist: "Emily Johnson",
            url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3")!
        ),
        Track(
            title: "Nightfall",
            artist: "The Harmonics",
            url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3")!
        )
    ]

    var body: some View {
        VStack(spacing: 16) {
            

            VStack(spacing: 4) {
                if audio.isBuffering {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 18)
                        .shimmering()
                        .padding(.horizontal, 40)
                } else if let track = audio.currentTrack {
                    Text(track.title)
                        .font(.title2).bold()
                    Text(track.artist)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)

            

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    
                    Capsule()
                        .foregroundColor(Color.gray.opacity(0.25))
                        .frame(height: 4)

                    
                    Capsule()
                        .foregroundColor(Color.gray.opacity(0.5))
                        .frame(width: bufferedWidth(totalWidth: geo.size.width), height: 4)

                    
                    Capsule()
                        .foregroundColor(Color.accentColor)
                        .frame(width: playedWidth(totalWidth: geo.size.width), height: 4)

                    
                    Slider(value: Binding(
                        get: { audio.currentTime },
                        set: { newValue in audio.seek(to: newValue) }
                    ), in: 0 ... max(audio.duration, 1))
                        .accentColor(.clear)
                        .background(Color.clear)
                        .frame(height: 24)
                }
            }
            .frame(height: 24)
            .padding(.horizontal)

            HStack {
                Text(format(audio.currentTime))
                Spacer()
                Text(format(audio.duration))
            }
            .font(.caption)
            .foregroundColor(.secondary)

            

            HStack(spacing: 40) {
                Button { audio.previous() } label: {
                    Image(systemName: "backward.fill").font(.title)
                }

                Button {
                    audio.isPlaying ? audio.pause() : audio.play()
                } label: {
                    Image(systemName: audio.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }

                Button { audio.next() } label: {
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

    

    private func bufferedWidth(totalWidth: CGFloat) -> CGFloat {
        guard audio.duration > 0 else { return 0 }
        let bufferedTime = audio.bufferedProgress * audio.duration
        let ratio = CGFloat(min(bufferedTime / audio.duration, 1.0))
        return totalWidth * ratio
    }

    private func playedWidth(totalWidth: CGFloat) -> CGFloat {
        guard audio.duration > 0 else { return 0 }
        let ratio = CGFloat(min(audio.currentTime / audio.duration, 1.0))
        return totalWidth * ratio
    }


    func format(_ t: Double) -> String {
        guard t.isFinite, t > 0 else { return "0:00" }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    ContentView()
}
