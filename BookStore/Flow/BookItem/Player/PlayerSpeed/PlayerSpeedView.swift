import ComposableArchitecture
import SwiftUI

struct PlayerSpeedView: View {
    
    let store: StoreOf<PlayerSpeed>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.playerSpeedTapped)
            } label: {
                Text("Speed \(viewStore.speed.displayValue)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(uiColor: .separator))
        }
    }
}

#Preview {
    PlayerSpeedView(
        store: Store(
            initialState: PlayerSpeed.State()
        ) {
            PlayerSpeed()
        }
    )
}
