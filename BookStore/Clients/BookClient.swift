import Foundation
import ComposableArchitecture

struct BookClient {
    
    var fetch: () async throws -> Book
}

extension BookClient: DependencyKey {
    
    static let liveValue = Self(
        fetch: {
            return Book.sample
        }
    )
}

extension DependencyValues {
    
    var bookClient: BookClient {
        get { self[BookClient.self] }
        set { self[BookClient.self] = newValue }
    }
}
