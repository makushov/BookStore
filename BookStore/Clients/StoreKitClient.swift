import StoreKit
import ComposableArchitecture

struct StoreKitClient {
    
    var fetchProduct: (String) async throws -> Product?
    var purchaseProduct: (Product) async throws -> Product.PurchaseResult
}

extension StoreKitClient: DependencyKey {
    
    static let liveValue = Self(
        fetchProduct: { productId in
            return try await Product.products(for: [productId]).first
        },
        purchaseProduct: { product in
            return try await product.purchase()
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
