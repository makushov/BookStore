import ComposableArchitecture
import SwiftUI

struct ChaptersListView: View {
    
    let store: StoreOf<ChaptersList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    ForEach(viewStore.chapters) { chapter in
                        Button {
                            viewStore.send(.chapterSelected(chapter))
                        } label: {
                            HStack {
                                Text(chapter.title)
                                    .fontWeight(viewStore.playingChapter?.id == chapter.id ? .bold : .regular)
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Text(chapter.timecode.displayableTimeCode)
                                    .timecodeStyle()
                            }
                        }
                    }
                }
                .navigationTitle("Chapters")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewStore.send(.close)
                        } label: {
                            Text("Close")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ChaptersListView(
        store: Store(
            initialState: ChaptersList.State(
                chapters: IdentifiedArrayOf(uniqueElements: Book.Chapter.sample),
                currentTimecode: 0
            )
        ) {
            ChaptersList()
        }
    )
}
