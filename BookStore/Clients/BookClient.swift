import Foundation
import ComposableArchitecture

struct BookClient {
    
    var fetch: () async throws -> Book
    var fetchArtwork: (URL) async throws -> Data?
}

extension BookClient: DependencyKey {
    
    static let liveValue = Self(
        fetch: {
            return Book.sample
        },
        fetchArtwork: { url in
            let data = try await URLSession.shared.data(from: url).0
            return data
        }
    )
}

extension DependencyValues {
    
    var bookClient: BookClient {
        get { self[BookClient.self] }
        set { self[BookClient.self] = newValue }
    }
}
