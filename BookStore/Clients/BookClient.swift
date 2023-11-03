import Foundation
import ComposableArchitecture
import SwiftUI

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
    
    static let testValue = Self(
        fetch: {
            return Book.sample
        },
        fetchArtwork: { _ in
            return UIImage(resource: .bookArtworkPlaceholder).heicData()!
        }
    )
}

extension DependencyValues {
    
    var bookClient: BookClient {
        get { self[BookClient.self] }
        set { self[BookClient.self] = newValue }
    }
}


