import ComposableArchitecture
import SwiftUI

@main
struct BookStoreApp: App {
    var body: some Scene {
        WindowGroup {
            BookItemView(
                store: Store(
                    initialState: BookItem.State()
                ) {
                    BookItem()
                }
            )
        }
    }
}
