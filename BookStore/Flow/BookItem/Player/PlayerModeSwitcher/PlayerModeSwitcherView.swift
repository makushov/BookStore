import ComposableArchitecture
import SwiftUI

struct PlayerModeSwitcherView: View {
    
    let store: StoreOf<PlayerModeSwitcher>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: .leastNonzeroMagnitude) {
                Button {
                    viewStore.send(.switchState(.player))
                } label: {
                    Image(systemName: "headphones")
                        .foregroundStyle(viewStore.mode == .player ? .white : .black)
                        .fontWeight(.bold)
                        .padding()
                }
                .background(viewStore.mode == .player ? .blue : .clear)
                .clipShape(Circle())
                .padding(.all, 2)
                
                Button {
                    viewStore.send(.switchState(.chapters))
                } label: {
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(viewStore.mode == .chapters ? .white : .black)
                        .fontWeight(.bold)
                        .padding()
                }
                .background(viewStore.mode == .chapters ? .blue : .clear)
                .clipShape(Circle())
                .padding(.all, 2)
            }
            .background(
                Capsule(style: .continuous)
                    .stroke(Color(.separator))
                    .fill(.white)
            )
        }
    }
}

#Preview {
    PlayerModeSwitcherView(
        store: Store(
            initialState: PlayerModeSwitcher.State()
        ) {
            PlayerModeSwitcher()
        }
    )
}
