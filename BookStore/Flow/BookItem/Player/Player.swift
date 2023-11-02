import Foundation
import ComposableArchitecture
import AVFoundation

struct Player: Reducer {
    
    struct State: Equatable {
        
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
    }
    
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
                
                return .none
                
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
                    } else {
                        do {
                            try AVAudioSession.sharedInstance().setCategory(.playback)
                            try AVAudioSession.sharedInstance().setActive(true)
                            
                            state.player.play()
                            state.playerControlState.isNowPlaying = true
                        } catch {
                            print(error.localizedDescription)
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
        
        return player
    }
}
