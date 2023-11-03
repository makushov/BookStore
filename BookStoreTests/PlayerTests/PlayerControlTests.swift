import ComposableArchitecture
import XCTest

@testable import BookStore

@MainActor
final class PlayerControlTests: XCTestCase {
    
    func testPlay() async {
        let store = TestStore(initialState: PlayerControl.State()) {
            PlayerControl()
        }
        
        await store.send(.playPauseTapped) {
            $0.isNowPlaying = true
        }
        
        await store.send(.playPauseTapped) {
            $0.isNowPlaying = false
        }
    }
}
