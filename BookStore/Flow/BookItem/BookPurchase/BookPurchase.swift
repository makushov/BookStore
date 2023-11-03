import Foundation
import ComposableArchitecture
import StoreKit

struct BookPurchase: Reducer {
    
    struct State: Equatable {
        
        var isPurchased: Bool = false
        var product: Product?
        var isLoading: Bool = false
        var isPurchasing: Bool = false
        
        var purchaseAvailable: Bool {
            return !isLoading && !isPurchasing && !isPurchased && product != nil
        }
    }
    
    enum Action: Equatable {
        
        case fetchProduct
        case fetchProductResponse(TaskResult<Product?>)
        case purchase
        case purchaseResponse(TaskResult<Product.PurchaseResult>)
        case checkSubscriptionStatus
        case checkSubscriptionStatusResponse(TaskResult<Product.SubscriptionInfo.Status?>)
        case error(PurchaseError)
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
                            TaskResult { try await storeClient.fetchProduct(SubscriptionPlans.oneYear.rawValue) }
                        )
                    )
                }
                
            case .fetchProductResponse(.success(let product)):
                state.product = product
                
                return .send(.checkSubscriptionStatus)
                
            case .fetchProductResponse(.failure(let error)):
                state.isLoading = false
                
                return .send(.error(.fetchError(error.localizedDescription)))
                
            case .purchase:
                guard let product = state.product else {
                    return .none
                }
                
                state.isPurchasing = true
                
                return .run { send in
                    await send(
                        .purchaseResponse(
                            TaskResult { try await storeClient.purchaseProduct(product) }
                        )
                    )
                }
                
            case .purchaseResponse(.success(let result)):
                state.isPurchasing = false
                
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        state.isPurchased = true
                        return .run { _ in
                            await transaction.finish()
                        }
                        
                    case .unverified(_, let error):
                        return .send(.error(.verificationError(error.localizedDescription)))
                    }
                    
                case .pending:
                    return .send(.error(.pending("Your purchase is in progress... ")))
                    
                default:
                    return .none
                }
                
            case .purchaseResponse(.failure(let error)):
                state.isPurchasing = false
                
                return .send(.error(.purchaseError(error.localizedDescription)))
                
            case .checkSubscriptionStatus:
                guard let product = state.product else {
                    state.isLoading = false
                    return .none
                }
                
                return .run { send in
                    await send(
                        .checkSubscriptionStatusResponse(
                            TaskResult { try await storeClient.checkSubscriptionStatus(product) }
                        )
                    )
                }
                
            case .checkSubscriptionStatusResponse(.success(let status)):
                state.isLoading = false
                
                if let status, case .subscribed = status.state {
                    state.isPurchased = true
                }
                
                return .none
                
            case .checkSubscriptionStatusResponse(.failure):
                state.isLoading = false
                
                return .none
                
            case .error:
                return .none
            }
        }
    }
}

enum PurchaseError: Equatable {
    
    case fetchError(String)
    case purchaseError(String)
    case verificationError(String)
    case pending(String)
    
    var message: String {
        switch self {
        case .fetchError(let message):
            return message
        case .purchaseError(let message):
            return message
        case .verificationError(let message):
            return message
        case .pending(let message):
            return message
        }
    }
}
