import ComposableArchitecture
import SwiftUI

struct PlayerView: View {
    
    let store: StoreOf<Player>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                PlayerProgressView(
                    store: store.scope(
                        state: \.playerProgressState,
                        action: Player.Action.playerProgress
                    )
                )
                
                PlayerSpeedView(
                    store: store.scope(
                        state: \.playerSpeedState,
                        action: Player.Action.playerSpeed
                    )
                )
                .padding(.top)
                
                PlayerControlView(
                    store: store.scope(
                        state: \.playerControlState,
                        action: Player.Action.playerControl
                    )
                )
                .padding(.top, 40)
                
                PlayerModeSwitcherView(
                    store: store.scope(
                        state: \.playerModeSwitcherState,
                        action: Player.Action.playerModeSwitcher
                    )
                )
                .padding(.top, 40)
            }
        }
    }
}

#Preview {
    PlayerView(
        store: Store(
            initialState: Player.State()
        ) {
            Player()
        }
    )
}
