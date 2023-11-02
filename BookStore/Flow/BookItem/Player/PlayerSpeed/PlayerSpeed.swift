import Foundation
import ComposableArchitecture

struct PlayerSpeed: Reducer {
    
    struct State: Equatable {
        
        var speed: Speed = .x1
        
        enum Speed: Double, CaseIterable {
            
            case x05 = 0.5
            case x1 = 1
            case x2 = 2
            
            var displayValue: String {
                switch self {
                case .x05: return "x0.5"
                case .x1: return "x1"
                case .x2: return "x2"
                }
            }
        }
    }
    
    enum Action: Equatable {
        
        case playerSpeedTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .playerSpeedTapped:
                switch state.speed {
                case .x05:
                    state.speed = .x1
                case .x1:
                    state.speed = .x2
                case .x2:
                    state.speed = .x05
                }
                
                return .none
            }
        }
    }
}
