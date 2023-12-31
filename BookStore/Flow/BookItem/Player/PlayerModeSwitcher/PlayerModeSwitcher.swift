import Foundation
import ComposableArchitecture

struct PlayerModeSwitcher: Reducer {
    
    struct State: Equatable {
        
        var mode: Mode = .player
        
        enum Mode {
            
            case player
            case chapters
        }
    }
    
    enum Action: Equatable {
        
        case switchState(PlayerModeSwitcher.State.Mode)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .switchState:
                return .none
            }
        }
    }
}
