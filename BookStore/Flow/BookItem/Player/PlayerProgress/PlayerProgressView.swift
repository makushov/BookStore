import ComposableArchitecture
import SwiftUI

struct PlayerProgressView: View {
    
    let store: StoreOf<PlayerProgress>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Text(viewStore.timePassedString)
                    .timecodeStyle()
                
                Slider(
                    value: viewStore.binding(
                        get: \.progress,
                        send: { PlayerProgress.Action.sliderValueChanged($0) }
                    ),
                    in: 0...viewStore.duration
                )
                .onAppear {
                    let thumbImage = UIImage(systemName: "circle.fill")
                    UISlider.appearance().setThumbImage(thumbImage, for: .normal)
                }
                
                Text(viewStore.timeLeftString)
                    .timecodeStyle()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    PlayerProgressView(
        store: Store(
            initialState: PlayerProgress.State(duration: 300)
        ) {
            PlayerProgress()
        }
    )
}
