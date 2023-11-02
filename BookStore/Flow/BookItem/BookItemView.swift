import ComposableArchitecture
import AVFoundation
import SwiftUI

struct BookItemView: View {
    
    let store: StoreOf<BookItem>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if let book = viewStore.book {
                    GeometryReader { proxy in
                        ZStack {
                            VStack {
                                AsyncImage(
                                    url: URL(string: book.artwork)
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
                                    Text("Key point \(index) of \(book.chapters.count)")
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
            .onReceive(
                NotificationCenter.default.publisher(
                    for: AVPlayerItem.didPlayToEndTimeNotification
                ), perform: { _ in
                    viewStore.send(.finishPlaying)
                }
            )
            .onReceive(
                viewStore.player.periodicTimePublisher(),
                perform: { time in
                    viewStore.send(.updateProgress(time.seconds))
                }
            )
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
