import AVFoundation

extension AVPlayer {
    
    var isNowPlaying: Bool {
        return rate != 0 && error == nil
    }
}
