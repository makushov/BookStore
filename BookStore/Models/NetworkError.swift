/// Common Network Error
enum NetworkError: Error {
    
    /// Request executing error with status code and message
    case httpError(Int, String)
    
    /// Decoding response error
    case parsing(String)
    
    /// Response data isn't a JSON
    case invalidData
    
    /// All other errors
    case `default`(Error)
    
    var message: String {
        switch self {
        case .httpError(let code, let message):
            guard code > 0 else {
                return "Your internet connection seems to be lost"
            }
            return message
        case .parsing(let errorText): return errorText
        case .invalidData: return "Received data is invalid"
        case .default(let error): return error.localizedDescription
        }
    }
}
