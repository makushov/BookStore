import Foundation

extension Double {
    
    var displayableTimeCode: String {
        let secondsInteger = Int(self)
        
        let hours = secondsInteger / 3600
        let minutes = (secondsInteger % 3600) / 60
        let seconds = (secondsInteger % 3600) % 60
        
        var resultString: String = ""
        
        if hours > 0 {
            resultString.append(hours < 10 ? "0\(hours):" : "\(hours):")
        }
        
        resultString.append(minutes < 10 ? "0\(minutes):" : "\(minutes):")
        resultString.append(seconds < 10 ? "0\(seconds)" : "\(seconds)")
        
        return resultString
    }
}
