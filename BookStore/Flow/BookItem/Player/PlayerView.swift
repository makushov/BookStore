import ComposableArchitecture
import MediaPlayer
import SwiftUI
import class AVFoundation.AVPlayerItem

struct PlayerView: View {
    
    let store: StoreOf<Player>
    
    @Dependency(\.playerClient) private var playerClient
    
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
            .onReceive(
                NotificationCenter.default.publisher(
                    for: AVPlayerItem.didPlayToEndTimeNotification
                ), perform: { _ in
                    viewStore.send(.finishPlaying)
                }
            )
            .onReceive(
                playerClient.periodicTimePublisher(),
                perform: { time in
                    viewStore.send(.updateProgress(time.seconds))
                }
            )
            .onReceive(
                MPRemoteCommandCenter.shared().remoteCommandPublisher(), perform: { event in
                    viewStore.send(.remoteControl(event))
                }
            )
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
