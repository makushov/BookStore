import Foundation
import ComposableArchitecture

struct PlayerProgress: Reducer {
    
    struct State: Equatable {
        
        var duration: Double = 0
        var progress: Double = 0
        
        var timePassedString: String {
            return progress.displayableTimeCode
        }
        
        var timeLeftString: String {
            return (duration - progress).displayableTimeCode
        }
    }
    
    enum Action: Equatable {
        
        case sliderValueChanged(Double)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .sliderValueChanged(let value):
                guard
                    value >= 0,
                    value <= state.duration
                else {
                    return .none
                }
                
                state.progress = value
                
                return .none
            }
        }
    }
}
