import ComposableArchitecture
import StoreKit
import XCTest

@testable import BookStore

@MainActor
final class ChaptersTests: XCTestCase {
    
    func testChapters() async {
        let chapters = Book.Chapter.sample
        
        let store = TestStore(
            initialState: ChaptersList.State(
                chapters: IdentifiedArrayOf(uniqueElements: chapters),
                currentTimecode: 0
            )
        ) {
            ChaptersList()
        }
        
        await store.send(.chapterSelected(chapters[1])) {
            $0.currentTimecode = chapters[1].timecode
        }
        
        await store.receive(.delegate(.chapterSelected(chapters[1])))
    }
}
