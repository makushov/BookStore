import Foundation
import ComposableArchitecture
import AVFoundation

struct BookItem: Reducer {
    
    struct State: Equatable {
        
        var book: Book?
        var playerState = Player.State()
        var purchaseState = BookPurchase.State()
        var player = AVPlayer()
        
        var currentKeyPointIndex: Int? {
            guard
                let chapter = getCurrentChapter(),
                let index = book?.chapters.firstIndex(where: { $0.id == chapter.id })
            else {
                return nil
            }
            
            return index + 1
        }
        
        var currentKeyPointTitle: String? {
            return getCurrentChapter()?.title
        }
        
        private func getCurrentChapter() -> Book.Chapter? {
            guard let book = book else {
                return nil
            }
            
            return book.chapters.last(where: { $0.timecode <= playerState.playerProgressState.progress })
        }
    }
    
    enum Action: Equatable {
        
        case fetchBook
        case bookResponse(Book)
        case player(Player.Action)
        case seekTo(Double)
        case updateProgress(Double)
        case finishPlaying
        case purchaseBook(BookPurchase.Action)
    }
    
    @Dependency(\.bookClient) var bookClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.playerState, action: /BookItem.Action.player) {
            Player()
        }
        
        Scope(state: \.purchaseState, action: /BookItem.Action.purchaseBook) {
            BookPurchase()
        }
        
        Reduce { state, action in
            switch action {
            case .fetchBook:
                return .run { send in
                    try await send(.bookResponse(bookClient.fetch()))
                }
                
            case .bookResponse(let book):
                state.book = book
                state.playerState.playerProgressState.duration = book.duration
                state.player = createPlayer(with: book, in: &state)
                return .none
                
            case .player(let action):
                return processPlayerAction(state: &state, action: action)
                
            case .seekTo(let progress):
                state.player.seek(
                    to: CMTime(seconds: progress, preferredTimescale: 60000),
                    toleranceBefore: .positiveInfinity,
                    toleranceAfter: .positiveInfinity
                )
                
                return .none
                
            case .finishPlaying:
                state.playerState.playerProgressState.progress = 0
                state.playerState.playerControlState.isNowPlaying = false
                state.player.pause()
                
                return .send(.seekTo(.zero))
            case .updateProgress(let progress):
                state.playerState.playerProgressState.progress = progress
                return .none
                
            case .purchaseBook(let action):
                switch action {
                case .fetchProductResponse(.failure(let error)):
                    // TODO: show error alert
                    return .none
                    
                case .purchaseResponse(.failure(let error)):
                    // TODO: show error alert
                    return .none
                    
                default:
                    return .none
                }
            }
        }
    }
    
    private func createPlayer(with book: Book, in state: inout State) -> AVPlayer {
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
    
    private func processPlayerAction(
        state: inout State,
        action: Player.Action
    ) -> Effect<Action> {
        switch action {
        case .playerControl(let controlAction):
            switch controlAction {
            case .backwardTapped:
                return .send(.seekTo(.zero))
                
            case .forwardTapped:
                guard let duration = state.book?.duration else {
                    return .none
                }
                
                return .send(.seekTo(duration))
                
            case .gobackword5Tapped:
                let timecode = max(0, state.playerState.playerProgressState.progress - 5)
                
                return .send(.seekTo(timecode))
                
            case .goforward10Tapped:
                let timecode = min(state.playerState.playerProgressState.duration, state.playerState.playerProgressState.progress + 10)
                
                return .send(.seekTo(timecode))
                
            case .playPauseTapped:
                if state.player.isNowPlaying == true {
                    state.player.pause()
                    state.playerState.playerControlState.isNowPlaying = false
                } else {
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                        try AVAudioSession.sharedInstance().setActive(true)
                        
                        state.player.play()
                        state.playerState.playerControlState.isNowPlaying = true
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                return .none
            }
            
        case .playerSpeed(let action):
            switch action {
            case .playerSpeedTapped:
                guard state.player.isNowPlaying == true else {
                    return .none
                }
                
                state.player.rate = Float(state.playerState.playerSpeedState.speed.rawValue)
                
                return .none
            }
            
        case .playerProgress(let action):
            switch action {
            case .sliderValueChanged(let progress):
                return .send(.seekTo(progress))
            }
            
        case .playerModeSwitcher:
            return .none
        }
    }
}
