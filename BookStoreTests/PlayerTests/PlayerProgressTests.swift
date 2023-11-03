import ComposableArchitecture
import StoreKit
import XCTest

@testable import BookStore

@MainActor
final class PlayerProgressTests: XCTestCase {
    
    func testProgress() async {
        let store = TestStore(initialState: PlayerProgress.State(duration: 100)) {
            PlayerProgress()
        }
        
        await store.send(.sliderValueChanged(10)) {
            $0.progress = 10
        }
        
        await store.send(.sliderValueChanged(30)) {
            $0.progress = 30
        }
    }
}
