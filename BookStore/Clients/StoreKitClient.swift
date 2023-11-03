import StoreKit
import ComposableArchitecture

protocol BookProduct {
    
    var id: String { get }
    var displayPrice: String { get }
}

struct StoreKitClient {
    
    var fetchProduct: (String) async throws -> Product?
    var purchaseProduct: (Product) async throws -> Product.PurchaseResult
    var checkSubscriptionStatus: (Product) async throws -> Product.SubscriptionInfo.Status?
}

extension StoreKitClient: DependencyKey {
    
    static let liveValue = Self(
        fetchProduct: { productId in
            return try await Product.products(for: [productId]).first
        },
        purchaseProduct: { product in
            return try await product.purchase()
        },
        checkSubscriptionStatus: { product in
            return try await product.subscription?.status.first
        }
    )
    
    static let testValue = Self(
        fetchProduct: { productId in
            return try await Product.products(for: [productId]).first
        },
        purchaseProduct: { product in
            return try await product.purchase()
        },
        checkSubscriptionStatus: { product in
            return try await product.subscription?.status.first
        }
    )
}

extension DependencyValues {
    
    var storeKitClient: StoreKitClient {
        get { self[StoreKitClient.self] }
        set {
            self[StoreKitClient.self] = newValue
        }
    }
}

extension Product: BookProduct {}
