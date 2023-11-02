import SwiftUI

struct TimecodeTextStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .monospacedDigit()
            .font(.system(size: 13))
            .foregroundStyle(.gray)
    }
}

extension Text {
    
    func timecodeStyle() -> some View {
        return modifier(TimecodeTextStyle())
    }
}
