import ComposableArchitecture
import SwiftUI

struct BookItemView: View {
    
    let store: StoreOf<BookItem>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if !viewStore.isLoading {
                    GeometryReader { proxy in
                        ZStack {
                            VStack {
                                AsyncImage(
                                    url: URL(string: viewStore.book?.artwork ?? "")
                                ) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                        .frame(height: 300)
                                }
                                .padding(.top)
                                
                                if let index = viewStore.currentKeyPointIndex {
                                    Text("Key point \(index) of \(viewStore.book?.chapters.count ?? 0)")
                                        .textCase(.uppercase)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.gray)
                                        .padding(.top, 20)
                                }
                                
                                if let keyPointTitle = viewStore.currentKeyPointTitle {
                                    Text(keyPointTitle)
                                        .font(.subheadline)
                                        .padding(.top)
                                }
                                
                                PlayerView(
                                    store: store.scope(
                                        state: \.playerState,
                                        action: BookItem.Action.player
                                    )
                                )
                                .padding(.vertical)
                            }
                            .background(Color.commonBackground)
                            
                            if !viewStore.purchaseState.isPurchased {
                                VStack {
                                    Spacer()
                                    
                                    BookPurchaseView(
                                        store: store.scope(
                                            state: \.purchaseState,
                                            action: BookItem.Action.purchaseBook
                                        )
                                    )
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [.clear, Color.commonBackground]
                                        ),
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .padding(.top, proxy.size.height / 4)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .task {
                viewStore.send(.fetchBook)
            }
        }
    }
}

#Preview {
    BookItemView(
        store: Store(
            initialState: BookItem.State()
        ) {
            BookItem()
        }
    )
}
