import Foundation
import AVFoundation
import MediaPlayer
import ComposableArchitecture
import Combine

struct PlayerClient {
    
    var createPlayer: (_ url: URL) -> Void
    var play: () throws -> Void
    var pause: () -> Void
    var seekTo: (_ timeinterval: TimeInterval) -> Void
    var setPlayingSpeed: (_ speed: Double) -> Void
    var updateNowPlayingInfo: (
        _ artist: String,
        _ title: String,
        _ duration: Double,
        _ progress: Double,
        _ rate: Double,
        _ artworkData: Data?
    ) -> Void
    var isNowPlaying: () -> Bool
    var periodicTimePublisher: () -> AnyPublisher<CMTime, Never>?
}

extension PlayerClient: DependencyKey {
    
    static let liveValue = Self(
        createPlayer: { url in
            PlayerService.shared.createPlayer(mediaUrl: url)
        },
        play: {
            try PlayerService.shared.play()
        },
        pause: {
            PlayerService.shared.pause()
        },
        seekTo: { timeinterval in
            PlayerService.shared.seekTo(timeinterval)
        },
        setPlayingSpeed: { speed in
            PlayerService.shared.setPlayingSpeed(speed)
        },
        updateNowPlayingInfo: { artist, title, duration, progress, rate, artworkData in
            PlayerService.shared.updateNowPlayingInfo(artist: artist, title: title, duration: duration, progress: progress, rate: rate, artworkData: artworkData)
        },
        isNowPlaying: {
            return PlayerService.shared.isNowPlaying
        },
        periodicTimePublisher: {
            return PlayerService.shared.periodicTimePublisher
        }
    )
}

extension DependencyValues {
    
    var playerClient: PlayerClient {
        get { self[PlayerClient.self] }
        set {
            self[PlayerClient.self] = newValue
        }
    }
}


fileprivate final class PlayerService {
    
    static let shared = PlayerService()
    
    var isNowPlaying: Bool { player?.isNowPlaying ?? false }
    var periodicTimePublisher: AnyPublisher<CMTime, Never>? { player?.periodicTimePublisher() }
    
    private var player: AVPlayer?
    
    func createPlayer(mediaUrl: URL) {
        let headers: [String: String] = [
            "Referer": "https://4read.org/"
        ]
        
        let asset = AVURLAsset(
            url: mediaUrl,
            options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
        )
        
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        setupRemoteControls()
    }
    
    func play() throws {
        guard let player else {
            return
        }
        
        if player.currentItem?.status == .readyToPlay {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player.play()
        } else {
            if let error = player.currentItem?.error {
                throw error
            }
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func seekTo(_ timeinterval: TimeInterval) {
        player?.seek(
            to: CMTime(seconds: timeinterval, preferredTimescale: 60000),
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity
        )
    }
    
    func setPlayingSpeed(_ speed: Double) {
        player?.rate = Float(speed)
    }
    
    func updateNowPlayingInfo(artist: String, title: String, duration: Double, progress: Double, rate: Double, artworkData: Data?) {
        var nowPlaying: [String: Any] = [
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: rate,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: progress
        ]
        
        if let artwork = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] {
            nowPlaying[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
        
        if nowPlaying[MPMediaItemPropertyArtwork] == nil {
            let updateArtwork: (Data, [String: Any]) -> Void = { imageData, nowPlaying in
                guard let image = UIImage(data: imageData) else {
                    return
                }
                
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                    return image
                }
                
                var updatedData = nowPlaying
                updatedData[MPMediaItemPropertyArtwork] = artwork
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = updatedData
            }
            
            if let artworkData {
                updateArtwork(artworkData, nowPlaying)
            }
        }
    }
    
    private func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [10]
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [5]
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
    }
}
