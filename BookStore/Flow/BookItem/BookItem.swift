import Foundation
import ComposableArchitecture

struct BookItem: Reducer {
    
    struct State: Equatable {
        
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
        case bookResponse(Book)
        case player(Player.Action)
        case purchaseBook(BookPurchase.Action)
    }
    
    @Dependency(\.bookClient) var bookClient
    
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
                    try await send(.bookResponse(bookClient.fetch()))
                }
                
            case .bookResponse(let book):
                state.book = book
                return .send(.player(.createPlayer(book)))
                
            case .player:
                return .none
                
            case .purchaseBook(let action):
                switch action {
                case .fetchProductResponse(.failure(let error)):
                    state.isLoading = false
                    // TODO: show error alert
                    return .none
                    
                case .purchaseResponse(.failure(let error)):
                    // TODO: show error alert
                    return .none
                  
                case .checkSubscriptionStatusResponse(.success):
                    state.isLoading = false
                    
                    return .none
                    
                case .checkSubscriptionStatusResponse(.failure(let error)):
                    // TODO: show error alert
                    state.isLoading = false
                    return .none
                    
                default:
                    return .none
                }
            }
        }
    }
}
