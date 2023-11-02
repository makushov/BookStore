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
                        
                        Group {
                            if viewStore.isLoading {
                                ProgressView()
                            } else {
                                Group {
                                    if let product = viewStore.product {
                                        Text("Start listening • \(product.displayPrice)")
                                    } else {
                                        Text("Unable to connect to AppStore")
                                    }
                                }
                                .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical)

                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 50)
                .disabled(!viewStore.purchaseAvailable)
            }
            .padding(.horizontal)
            .onAppear {
                viewStore.send(.fetchProduct)
            }
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
