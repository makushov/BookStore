import ComposableArchitecture
import SwiftUI

struct PlayerControlView: View {
    
    let store: StoreOf<PlayerControl>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 25) {
                Button {
                    viewStore.send(.backwardTapped)
                } label: {
                    Image(systemName: "backward.end.fill")
                        .playerButtonStyle()
                }
                
                Button {
                    viewStore.send(.gobackword5Tapped)
                } label: {
                    Image(systemName: "gobackward.5")
                        .playerButtonStyle()
                }
                
                Button {
                    viewStore.send(.playPauseTapped)
                } label: {
                    Image(systemName: viewStore.isNowPlaying ? "pause.fill" : "play.fill")
                        .playerButtonStyle(size: .large)
                }
                
                Button {
                    viewStore.send(.goforward10Tapped)
                } label: {
                    Image(systemName: "goforward.10")
                        .playerButtonStyle()
                }
                
                Button {
                    viewStore.send(.forwardTapped)
                } label: {
                    Image(systemName: "forward.end.fill")
                        .playerButtonStyle()
                }
            }
        }
    }
}

#Preview {
    PlayerControlView(
        store: Store(
            initialState: PlayerControl.State()
        ) {
            PlayerControl()
        }
    )
}
