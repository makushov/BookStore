import ComposableArchitecture
import SwiftUI

struct BookPurchaseView: View {
    
    let store: StoreOf<BookPurchase>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 30) {
                Text("Unlock learning")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Grow on the go by listening and reading the world's best ideas")
                    .multilineTextAlignment(.center)
                
                Button {
                    viewStore.send(.purchase)
                } label: {
                    HStack {
                        Spacer()
                        
                        Text("Start listening • $89.99")
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 50)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    BookPurchaseView(
        store: Store(
            initialState: BookPurchase.State(isPurchased: false)
        ) {
            BookPurchase()
        }
    )
}
