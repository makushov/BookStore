import ComposableArchitecture
import AVFoundation
import StoreKit
import XCTest

@testable import BookStore

@MainActor
final class PlayerTests: XCTestCase {
    
    func testPlayerSeekOptions() async {
        let store = TestStore(initialState: Player.State()) {
            Player()
        }
        
        let book = Book.sample
        
        guard let placeholderArtworkData = UIImage(resource: .bookArtworkPlaceholder).heicData() else {
            XCTFail("No image data")
            return
        }
        
        await store.send(.createPlayer(book)) {
            $0.book = Book.sample
            $0.playerProgressState.duration = book.duration
        }
        
        await store.send(.playerControl(.goforward10Tapped))
        await store.receive(.seekTo(10))
        await store.receive(.updateProgress(10)) {
            $0.playerProgressState.progress = 10
        }
        
        await store.receive(.loadArtwork)
        await store.receive(.loadArtworkResponse(.success(placeholderArtworkData)))
        await store.receive(.updateArtwork(placeholderArtworkData)) {
            $0.artworkImageData = placeholderArtworkData
        }
        
        await store.send(.playerControl(.gobackword5Tapped))
        await store.receive(.seekTo(5))
        await store.receive(.updateProgress(5)) {
            $0.playerProgressState.progress = 5
        }
        
        await store.send(.playerControl(.backwardTapped))
        await store.receive(.seekTo(.zero))
        await store.receive(.updateProgress(.zero)) {
            $0.playerProgressState.progress = .zero
        }
        
        await store.send(.playerControl(.forwardTapped))
        await store.receive(.seekTo(book.duration))
        await store.receive(.updateProgress(book.duration)) {
            $0.playerProgressState.progress = book.duration
        }
    }
}
