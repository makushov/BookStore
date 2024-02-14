import Foundation
import ComposableArchitecture

@Reducer
struct BookItem {
    
    struct State: Equatable {
        
        @PresentationState var destination: Destination.State?
        var book: Book?
        var playerState = Player.State()
        var purchaseState = BookPurchase.State()
        var isLoading: Bool = false
        
        var currentKeyPointIndex: Int? {
            guard
                let chapter = getCurrentChapter(),
                let index = book?.chapters.firstIndex(where: { $0.id == chapter.id })
            else {
                return nil
            }
            
            return index + 1
        }
        
        var currentKeyPointTitle: String? {
            return getCurrentChapter()?.title
        }
        
        private func getCurrentChapter() -> Book.Chapter? {
            guard let book = book else {
                return nil
            }
            
            return book.chapters.last(where: { $0.timecode <= playerState.playerProgressState.progress })
        }
    }
    
    enum Action: Equatable {
        
        case fetchBook
        case bookResponse(TaskResult<Book>)
        case player(Player.Action)
        case purchaseBook(BookPurchase.Action)
        case destination(PresentationAction<Destination.Action>)
        
        enum Alert: Equatable {
            
            case errorMessage(String)
        }
    }
    
    @Dependency(\.bookClient) private var bookClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.playerState, action: /BookItem.Action.player) {
            Player()
        }
        
        Scope(state: \.purchaseState, action: /BookItem.Action.purchaseBook) {
            BookPurchase()
        }
        
        Reduce { state, action in
            switch action {
            case .fetchBook:
                state.isLoading = true
                
                return .run { send in
                    await send(
                        .bookResponse(
                            TaskResult { try await bookClient.fetch() }
                        )
                    )
                }
                
            case .bookResponse(.success(let book)):
                state.isLoading = false
                state.book = book
                return .send(.player(.createPlayer(book)))
                
            case .bookResponse(.failure(let error)):
                state.isLoading = false
                
                let errorMessage: String
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.message
                } else {
                    errorMessage = error.localizedDescription
                }
                
                state.destination = .alert(.error(message: errorMessage))
                return .none

            case let .purchaseBook(.error(error)):
                state.isLoading = false
                state.destination = .alert(.error(message: error.message))
                return .none
                
            case let .player(.error(error)):
                state.destination = .alert(.error(message: error.message))
                state.isLoading = false
                return .none
                
            case let .player(.playerModeSwitcher(.switchState(mode))):
                guard mode == .chapters else {
                    return .none
                }
                
                state.destination = .chaptersList(
                    ChaptersList.State(
                        chapters: IdentifiedArrayOf(
                            uniqueElements: state.book?.chapters ?? []
                        ),
                        currentTimecode: state.playerState.playerProgressState.progress
                    )
                )
                
                return .none
                
            case let .destination(.presented(.chaptersList(.chapterSelected(chapter)))):
                return .send(.player(.seekTo(chapter.timecode)))
                
            case .player:
                return .none
                
            case .purchaseBook:
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension BookItem {
    
    struct Destination: Reducer {
        
        enum State: Equatable {
            
            case chaptersList(ChaptersList.State)
            case alert(AlertState<BookItem.Action.Alert>)
        }
        
        enum Action: Equatable {
            
            case chaptersList(ChaptersList.Action)
            case alert(BookItem.Action.Alert)
        }
        
        var body: some ReducerOf<Self> {
            Scope(
                state: /State.chaptersList,
                action: /Action.chaptersList
            ) {
                ChaptersList()
            }
        }
    }
}

extension AlertState where Action == BookItem.Action.Alert {
    
    static func error(message: String) -> Self {
        Self(
            title: TextState("Oh no, something went wrong..."),
            message: TextState(message)
        )
    }
}
