import Foundation
import ComposableArchitecture
import AVFoundation
import MediaPlayer

struct Player: Reducer {
    
    struct State: Equatable {
        
        var book: Book?
        var artworkImageData: Data?
        var isArtworkLoading: Bool = false
        var player = AVPlayer()
        var playerProgressState = PlayerProgress.State()
        var playerSpeedState = PlayerSpeed.State()
        var playerControlState = PlayerControl.State()
        var playerModeSwitcherState = PlayerModeSwitcher.State()
    }
    
    enum Action: Equatable {
        
        case createPlayer(Book)
        case seekTo(Double)
        case updateProgress(Double)
        case finishPlaying
        case playerProgress(PlayerProgress.Action)
        case playerSpeed(PlayerSpeed.Action)
        case playerControl(PlayerControl.Action)
        case playerModeSwitcher(PlayerModeSwitcher.Action)
        case loadArtwork
        case loadArtworkResponse(TaskResult<Data?>)
        case updateArtwork(Data)
        case remoteControl(MPRemoteCommandCenter.MediaEvent)
    }
    
    @Dependency(\.bookClient) var bookClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.playerProgressState, action: /Player.Action.playerProgress) {
            PlayerProgress()
        }
        
        Scope(state: \.playerSpeedState, action: /Player.Action.playerSpeed) {
            PlayerSpeed()
        }
        
        Scope(state: \.playerControlState, action: /Player.Action.playerControl) {
            PlayerControl()
        }
        
        Scope(state: \.playerModeSwitcherState, action: /Player.Action.playerModeSwitcher) {
            PlayerModeSwitcher()
        }
        
        Reduce { state, action in
            switch action {
            case .createPlayer(let book):
                state.book = book
                state.playerProgressState.duration = book.duration
                state.player = createPlayer(with: book)
                
                return .none
                
            case .seekTo(let progress):
                state.player.seek(
                    to: CMTime(seconds: progress, preferredTimescale: 60000),
                    toleranceBefore: .positiveInfinity,
                    toleranceAfter: .positiveInfinity
                )
                
                return .none
                
            case .updateProgress(let progress):
                state.playerProgressState.progress = progress
                
                return updateNowPlayingInfo(state: &state)
                
            case .finishPlaying:
                state.playerProgressState.progress = 0
                state.playerControlState.isNowPlaying = false
                state.player.pause()
                
                return .send(.seekTo(.zero))
                
            case .playerSpeed(let action):
                switch action {
                case .playerSpeedTapped:
                    guard state.player.isNowPlaying == true else {
                        return .none
                    }
                    
                    state.player.rate = Float(state.playerSpeedState.speed.rawValue)
                    
                    return .none
                }
                
            case .playerControl(let playerControlAction):
                switch playerControlAction {
                case .backwardTapped:
                    return .send(.seekTo(.zero))
                    
                case .forwardTapped:
                    guard let duration = state.player.currentItem?.duration.seconds else {
                        return .none
                    }
                    
                    return .send(.seekTo(duration))
                    
                case .gobackword5Tapped:
                    return .send(.seekTo(max(state.playerProgressState.progress - 5, 0)))
                    
                case .goforward10Tapped:
                    return .send(.seekTo(min(state.playerProgressState.progress + 10, state.playerProgressState.duration)))
                    
                case .playPauseTapped:
                    if state.player.isNowPlaying == true {
                        state.player.pause()
                        state.playerControlState.isNowPlaying = false
                        return updateNowPlayingInfo(state: &state)
                    } else {
                        if state.player.currentItem?.status == .readyToPlay {
                            do {
                                try AVAudioSession.sharedInstance().setCategory(.playback)
                                try AVAudioSession.sharedInstance().setActive(true)
                                
                                state.player.play()
                                state.player.rate = Float(state.playerSpeedState.speed.rawValue)
                                state.playerControlState.isNowPlaying = true
                                
                                return updateNowPlayingInfo(state: &state)
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else {
                            // TODO: handle playback error
                        }
                    }
                    
                    return .none
                }
            case .playerModeSwitcher:
                return .none
                
            case .playerProgress(let action):
                switch action {
                case .sliderValueChanged(let progress):
                    return .send(.seekTo(progress))
                }
                
            case .loadArtwork:
                guard
                    let urlString = state.book?.artwork,
                    let url = URL(string: urlString)
                else {
                    return .none
                }
                
                state.isArtworkLoading = false
                
                return .run { send in
                    await send(
                        .loadArtworkResponse(
                            TaskResult { try await bookClient.fetchArtwork(url) }
                        )
                    )
                }
                
            case .loadArtworkResponse(.failure):
                state.isArtworkLoading = false
                return .none
                
            case .loadArtworkResponse(.success(let data)):
                guard let artworkData = data else {
                    return .none
                }
                
                return .send(.updateArtwork(artworkData))
                
            case .updateArtwork(let data):
                state.artworkImageData = data
                state.isArtworkLoading = false
                
                return updateNowPlayingInfo(state: &state)
                
            case .remoteControl(let event):
                switch event {
                case .play:
                    return .send(.playerControl(.playPauseTapped))
                case .pause:
                    return .send(.playerControl(.playPauseTapped))
                case .seekBackward:
                    return .send(.playerControl(.gobackword5Tapped))
                case .seekForward:
                    return .send(.playerControl(.goforward10Tapped))
                case .seekTo(let progress):
                    return .send(.seekTo(progress))
                }
            }
        }
    }
    
    private func createPlayer(with book: Book) -> AVPlayer {
        guard let url = URL(string: book.mediaUrl) else {
            return AVPlayer()
        }
        
        let headers: [String: String] = [
            "Referer": "https://4read.org/"
        ]
        
        let asset = AVURLAsset(
            url: url,
            options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
        )
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        setupRemoteControls()
        
        return player
    }
    
    private func updateNowPlayingInfo(state: inout State) -> Effect<Player.Action> {
        guard let book = state.book else {
            return .none
        }
        
        var nowPlaying: [String: Any] = [
            MPMediaItemPropertyArtist: book.author,
            MPMediaItemPropertyTitle: book.title,
            MPMediaItemPropertyPlaybackDuration: book.duration,
            MPNowPlayingInfoPropertyPlaybackRate: state.playerControlState.isNowPlaying ? state.playerSpeedState.speed.rawValue : 0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: state.playerProgressState.progress
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
            
            if let data = state.artworkImageData {
                updateArtwork(data, nowPlaying)
                return .none
            } else {
                return .send(.loadArtwork)
            }
        } else {
            return .none
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
