import Foundation
import ComposableArchitecture

struct BookPurchase: Reducer {
    
    struct State: Equatable {
        
        var isPurchased: Bool
    }
    
    enum Action: Equatable {
        
        case purchase
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .purchase:
                state.isPurchased.toggle()
                return .none
            }
        }
    }
}
