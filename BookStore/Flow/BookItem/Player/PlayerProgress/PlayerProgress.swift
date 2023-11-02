import Foundation
import ComposableArchitecture

struct PlayerProgress: Reducer {
    
    struct State: Equatable {
        
        var duration: Double = 0
        var progress: Double = 0
        
        var timePassedString: String {
           return secondsToHoursMinutesSeconds(Int(progress))
        }
        
        var timeLeftString: String {
            return secondsToHoursMinutesSeconds(Int(duration - progress))
        }
        
        private func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let seconds = (seconds % 3600) % 60
            
            var resultString: String = ""
            
            if hours > 0 {
                resultString.append(hours < 10 ? "0\(hours):" : "\(hours):")
            }
            
            resultString.append(minutes < 10 ? "0\(minutes):" : "\(minutes):")
            resultString.append(seconds < 10 ? "0\(seconds)" : "\(seconds)")
            
            return resultString
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
