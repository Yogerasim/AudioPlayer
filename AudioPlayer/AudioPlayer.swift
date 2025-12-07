import AVFoundation
import Combine

class AudioPlayer: NSObject, ObservableObject {
    @Published var currentTrack: Track?
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isPlaying: Bool = false
    @Published var isBuffering: Bool = false

    private var playlist: [Track] = []
    private var index: Int = 0
    private var player: AVPlayer?
    private var timer: AnyCancellable?

    // MARK: - Playlist
    func loadPlaylist(_ tracks: [Track]) {
        playlist = tracks
        index = 0
        playCurrent()
    }

    private func playCurrent() {
        guard playlist.indices.contains(index) else { return }
        let track = playlist[index]
        currentTrack = track

        let item = AVPlayerItem(url: track.url)
        observeBuffering(item)

        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true

        observeTime()

        item.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async {
                let sec = CMTimeGetSeconds(item.asset.duration)
                self.duration = sec.isFinite ? sec : 0
            }
        }
    }

    // MARK: - Controls
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

    // MARK: - Buffering state
    private func observeBuffering(_ item: AVPlayerItem) {
        item.addObserver(self, forKeyPath: "isPlaybackBufferEmpty", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "isPlaybackLikelyToKeepUp", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "isPlaybackBufferEmpty" {
            isBuffering = true
        }
        if keyPath == "isPlaybackLikelyToKeepUp" {
            isBuffering = false
        }
    }

    // MARK: - Time observer
    private func observeTime() {
        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let s = self,
                      let sec = s.player?.currentTime().seconds,
                      sec.isFinite else { return }
                s.currentTime = sec
            }
    }
}

