import ComposableArchitecture
import StoreKit
import XCTest

@testable import BookStore

@MainActor
final class PlayerSpeedTests: XCTestCase {
    
    func testProgress() async {
        let store = TestStore(initialState: PlayerSpeed.State()) {
            PlayerSpeed()
        }
        
        await store.send(.playerSpeedTapped) {
            $0.speed = .x2
        }
        
        await store.send(.playerSpeedTapped) {
            $0.speed = .x05
        }
        
        await store.send(.playerSpeedTapped) {
            $0.speed = .x1
        }
    }
}
