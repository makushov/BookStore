import Foundation
import ComposableArchitecture
import StoreKit

struct BookPurchase: Reducer {
    
    struct State: Equatable {
        
        var isPurchased: Bool = false
        var product: Product?
        var isLoading: Bool = false
        
        var purchaseAvailable: Bool {
            return !isLoading && product != nil
        }
    }
    
    enum Action: Equatable {
        
        case fetchProduct
        case fetchProductResponse(TaskResult<Product?>)
        case purchase
        case purchaseResponse(TaskResult<Product.PurchaseResult>)
    }
    
    @Dependency(\.storeKitClient) var storeClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchProduct:
                state.isLoading = true
                
                return .run { send in
                    await send(
                        .fetchProductResponse(
                            TaskResult { try await storeClient.fetchProduct("one_year") }
                        )
                    )
                }
                
            case .fetchProductResponse(.success(let product)):
                state.product = product
                state.isLoading = false
                
                return .none
                
            case .fetchProductResponse(.failure):
                state.isLoading = false
                
                return .none
                
            case .purchase:
                guard let product = state.product else {
                    return .none
                }
                
                state.isLoading = true
                
                return .run { send in
                    await send(
                        .purchaseResponse(
                            TaskResult { try await storeClient.purchaseProduct(product) }
                        )
                    )
                }
                
            case .purchaseResponse(.success(let result)):
                state.isLoading = false
                
                switch result {
                case .success:
                    state.isPurchased = true
                    
                    return .none
                default:
                    return .none
                }
                
            case .purchaseResponse(.failure):
                state.isLoading = false
                
                return .none
            }
        }
    }
}
