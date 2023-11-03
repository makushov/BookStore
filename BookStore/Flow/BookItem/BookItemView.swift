import ComposableArchitecture
import SwiftUI

struct BookItemView: View {
    
    let store: StoreOf<BookItem>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
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
                                Image(.bookArtworkPlaceholder)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .redacted(reason: viewStore.book?.artwork == nil ? .placeholder : [])
                            }
                            .padding(.top)
                            .redacted(reason: viewStore.isLoading ? .placeholder : [])
                            
                            Text("Key point \(viewStore.currentKeyPointIndex ?? 0) of \(viewStore.book?.chapters.count ?? 0)")
                                .textCase(.uppercase)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.gray)
                                .padding(.top, 20)
                                .redacted(reason: viewStore.isLoading ? .placeholder : [])
                            
                            Text(viewStore.currentKeyPointTitle ?? "\n")
                                .font(.subheadline)
                                .padding(.top)
                                .redacted(reason: viewStore.isLoading ? .placeholder : [])

                            
                            PlayerView(
                                store: store.scope(
                                    state: \.playerState,
                                    action: BookItem.Action.player
                                )
                            )
                            .padding(.vertical)
                            .redacted(reason: viewStore.isLoading ? .placeholder : [])
                        }
                        
                        if !viewStore.purchaseState.isPurchased {
                            VStack {
                                Spacer()
                                
                                BookPurchaseView(
                                    store: store.scope(
                                        state: \.purchaseState,
                                        action: BookItem.Action.purchaseBook
                                    )
                                )
                                .redacted(reason: viewStore.isLoading ? .placeholder : [])
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
                    .background(Color.commonBackground)
                }
            }
            .onAppear {
                viewStore.send(.fetchBook)
            }
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /BookItem.Destination.State.chaptersList,
                action: BookItem.Destination.Action.chaptersList
            ) { chaptersListStore in
                ChaptersListView(store: chaptersListStore)
            }
            .alert(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /BookItem.Destination.State.alert,
                action: BookItem.Destination.Action.alert
            )
        }
    }
}

#Preview {
    BookItemView(
        store: Store(
            initialState: BookItem.State(
                purchaseState: BookPurchase.State(isPurchased: true)
            )
        ) {
            BookItem()
        }
    )
}
