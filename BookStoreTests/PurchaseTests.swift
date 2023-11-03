import ComposableArchitecture
import StoreKit
import XCTest

@testable import BookStore

@MainActor
final class PurchaseTests: XCTestCase {
    
    func testPurchase() async {
        let store = TestStore(initialState: BookPurchase.State()) {
            BookPurchase()
        }
        
        guard let product = try? await Product.products(for: [SubscriptionPlans.oneYear.rawValue]).first else {
            XCTFail("Unable to fetch sample product")
            return
        }
        
        guard let subscriptionStatus = try? await product.subscription?.status.first else {
            XCTFail("Unable to fetch sample subscription status")
            return
        }
        
        await store.send(.fetchProduct) {
            $0.isLoading = true
        }
        
        await store.receive(.fetchProductResponse(.success(product))) {
            $0.product = product
        }
        
        await store.receive(.checkSubscriptionStatus)
        
        await store.receive(.checkSubscriptionStatusResponse(.success(subscriptionStatus))) {
            $0.isPurchased = subscriptionStatus.state == .subscribed
            $0.isLoading = false
        }
    }
}
