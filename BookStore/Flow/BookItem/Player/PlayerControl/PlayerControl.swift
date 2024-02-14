import Foundation
import ComposableArchitecture

@Reducer
struct PlayerControl {
    
    struct State: Equatable {
        
        var isNowPlaying: Bool = false
    }
    
    enum Action: Equatable {
        
        case playPauseTapped
        case backwardTapped
        case forwardTapped
        case goforward10Tapped
        case gobackword5Tapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .playPauseTapped:
                state.isNowPlaying.toggle()
                return .none
                
            default:
                return .none
            }
        }
    }
}
