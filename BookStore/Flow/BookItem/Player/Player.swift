import Foundation
import ComposableArchitecture
import AVFoundation
import MediaPlayer
import Combine

@Reducer
struct Player {
    
    struct State: Equatable {
        
        var book: Book?
        var artworkImageData: Data?
        var isArtworkLoading: Bool = false
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
        case error(PlayerError)
    }
    
    @Dependency(\.bookClient) private var bookClient
    @Dependency(\.playerClient) private var playerClient
    
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
                
                if let url = URL(string: book.mediaUrl) {
                    playerClient.createPlayer(url)
                }
                
                return .send(.loadArtwork)
                
            case .seekTo(let progress):
                playerClient.seekTo(progress)
                
                return .send(.updateProgress(progress))
                
            case .updateProgress(let progress):
                state.playerProgressState.progress = progress
                updateNowPlayingInfo(state)
                
                return .none
                
            case .finishPlaying:
                state.playerProgressState.progress = 0
                state.playerControlState.isNowPlaying = false
                playerClient.pause()
                
                return .send(.seekTo(.zero))
                
            case .playerSpeed(let action):
                switch action {
                case .playerSpeedTapped:
                    guard playerClient.isNowPlaying() else {
                        return .none
                    }
                    
                    playerClient.setPlayingSpeed(state.playerSpeedState.speed.rawValue)
                    
                    return .none
                }
                
            case .playerControl(let playerControlAction):
                switch playerControlAction {
                case .backwardTapped:
                    return .send(.seekTo(.zero))
                    
                case .forwardTapped:
                    return .send(.seekTo(state.playerProgressState.duration))
                    
                case .gobackword5Tapped:
                    return .send(.seekTo(max(state.playerProgressState.progress - 5, 0)))
                    
                case .goforward10Tapped:
                    return .send(.seekTo(min(state.playerProgressState.progress + 10, state.playerProgressState.duration)))
                    
                case .playPauseTapped:
                    if playerClient.isNowPlaying() {
                        playerClient.pause()
                        state.playerControlState.isNowPlaying = false
                        
                        updateNowPlayingInfo(state)
                        
                        return .none
                    } else {
                        do {
                            try playerClient.play()
                            playerClient.setPlayingSpeed(state.playerSpeedState.speed.rawValue)
                            state.playerControlState.isNowPlaying = true
                            
                            return .none
                        } catch {
                            state.playerControlState.isNowPlaying = false
                            
                            if let book = state.book, let url = URL(string: book.mediaUrl) {
                                playerClient.createPlayer(url)
                            }
                            
                            return .send(
                                .error(
                                    .playbackError(error.localizedDescription)
                                )
                            )
                        }
                    }
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
                
                updateNowPlayingInfo(state)
                
                return .none
                
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
                
            case .error:
                return .none
            }
        }
    }
    
    private func updateNowPlayingInfo(_ state: State) {
        playerClient.updateNowPlayingInfo(
            state.book?.author ?? "",
            state.book?.title ?? "",
            state.book?.duration ?? 0,
            state.playerProgressState.progress,
            state.playerControlState.isNowPlaying ? state.playerSpeedState.speed.rawValue : 0,
            state.artworkImageData
        )
    }
}

enum PlayerError: Error, Equatable {
    
    case playbackError(String)
    
    var message: String {
        switch self {
        case .playbackError(let message):
            return message
        }
    }
}
