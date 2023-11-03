import Foundation
import ComposableArchitecture

struct ChaptersList: Reducer {
    
    struct State: Equatable {
        
        let chapters: IdentifiedArrayOf<Book.Chapter>
        var currentTimecode: Double
        
        var playingChapter: Book.Chapter? {
            guard currentTimecode > 0 else {
                return nil
            }
            
            return chapters.last(where: { $0.timecode <= currentTimecode })
        }
    }
    
    enum Action: Equatable {
        
        case delegate(Delegate)
        case chapterSelected(Book.Chapter)
        case close
        
        enum Delegate: Equatable {

            case chapterSelected(Book.Chapter)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .chapterSelected(let chapter):
                state.currentTimecode = chapter.timecode
                
                return .run { send in
                    await send(.delegate(.chapterSelected(chapter)))
                }
                
            case .close:
                return .run { _ in
                    await self.dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
