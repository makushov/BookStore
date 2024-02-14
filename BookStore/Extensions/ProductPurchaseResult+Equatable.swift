import StoreKit

extension Product.PurchaseResult: Equatable {
    
    public static func == (lhs: Product.PurchaseResult, rhs: Product.PurchaseResult) -> Bool {
        switch lhs {
        case .success(let lhsVerificationResult):
            if case let .success(rhsVerificationResult) = rhs {
                return lhsVerificationResult == rhsVerificationResult
            }
            
            return false
        case .userCancelled:
            return rhs == .userCancelled
        case .pending:
            return rhs == .pending
        @unknown default:
            return false
        }
    }
}
