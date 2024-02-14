import Foundation
import ComposableArchitecture
import SwiftUI
import RealHTTP

struct BookClient {
    
    var fetch: @Sendable () async throws -> Book
    var fetchArtwork: @Sendable (URL) async throws -> Data?
}

extension BookClient: DependencyKey {
    
    static let liveValue = Self(
        fetch: {
            let request = HTTPRequest {
                $0.path = "https://raw.githubusercontent.com/makushov/BookStore/main/book.json"
                $0.method = .get
            }
            
            let response = try await request.fetch()
            
            if let data = response.data {
                return try JSONDecoder().decode(Book.self, from: data)
            } else {
                if response.isError, let responseError = response.error {
                    switch responseError.category {
                    case .timeout:
                        throw NetworkError.httpError(0, "Request timed out")
                    case .network, .missingConnection:
                        throw NetworkError.httpError(0, "Your internet connection seems to be lost")
                    default:
                        throw NetworkError.httpError(responseError.statusCode.rawValue, responseError.description)
                    }
                } else {
                    throw NetworkError.invalidData
                }
            }
        },
        fetchArtwork: { url in
            return try await URLSession.shared.data(from: url).0
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


