import SwiftUI

struct PlayerButtonStyle: ViewModifier {
    
    enum Size: CGFloat {
        
        case regular = 25
        case large = 40
    }
    
    let size: Size
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size.rawValue, weight: .bold))
            .foregroundStyle(.black)
    }
}

extension View {
    
    func playerButtonStyle(size: PlayerButtonStyle.Size = .regular) -> some View {
        modifier(PlayerButtonStyle(size: size))
    }
}
