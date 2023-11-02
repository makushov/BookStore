import Foundation
import ComposableArchitecture

struct Player: Reducer {
    
    struct State: Equatable {
        
        var playerProgressState = PlayerProgress.State()
        var playerSpeedState = PlayerSpeed.State()
        var playerControlState = PlayerControl.State()
        var playerModeSwitcherState = PlayerModeSwitcher.State()
    }
    
    enum Action: Equatable {
        
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
            case .playerSpeed:
                return .none
                
            case .playerControl(let playerControlAction):
                switch playerControlAction {
                case .backwardTapped:
                    return .send(.playerProgress(.sliderValueChanged(0)))
                    
                case .forwardTapped:
                    return .send(.playerProgress(.sliderValueChanged(state.playerProgressState.duration)))
                    
                case .gobackword5Tapped:
                    return .send(.playerProgress(.sliderValueChanged(max(state.playerProgressState.progress - 5, 0))))
                    
                case .goforward10Tapped:
                    return .send(.playerProgress(.sliderValueChanged(min(state.playerProgressState.progress + 10, state.playerProgressState.duration))))
                    
                default:
                    return .none
                }
            case .playerModeSwitcher:
                return .none
                
            case .playerProgress:
                return .none
            }
        }
    }
}
