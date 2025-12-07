import AVFoundation
import Combine
import SwiftUI

class AudioPlayer: NSObject, ObservableObject {
    @Published var currentTrack: Track?
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isPlaying: Bool = false
    @Published var isBuffering: Bool = false
    @Published var bufferedProgress: Double = 0

    private var playlist: [Track] = []
    private var index: Int = 0
    private var player: AVPlayer?
    private var timer: AnyCancellable?

    func loadPlaylist(_ tracks: [Track]) {
        playlist = tracks
        index = 0
        playCurrent()
    }

    private func playCurrent() {
        guard playlist.indices.contains(index) else { return }
        let track = playlist[index]
        currentTrack = track
        isBuffering = true

        let item = AVPlayerItem(url: track.url)
        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true

        item.asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                let sec = CMTimeGetSeconds(item.asset.duration)
                self.duration = sec.isFinite ? sec : 0
            }
        }

        observeTime()
    }

    func play() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func next() {
        guard index < playlist.count - 1 else { return }
        index += 1
        playCurrent()
    }

    func previous() {
        guard index > 0 else { return }
        index -= 1
        playCurrent()
    }

    func seek(to time: Double) {
        let cm = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cm)
    }

    private func observeTime() {
        timer?.cancel()
        timer = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                if let sec = player?.currentTime().seconds, sec.isFinite {
                    currentTime = sec
                }

                if let item = player?.currentItem,
                   let range = item.loadedTimeRanges.first?.timeRangeValue
                {
                    let buffered = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration)
                    bufferedProgress = duration > 0 ? min(buffered / duration, 1) : 0
                }

                if currentTime >= bufferedProgress * duration {
                    isBuffering = true
                } else {
                    isBuffering = false
                }
            }
    }

    deinit {
        timer?.cancel()
    }
}
