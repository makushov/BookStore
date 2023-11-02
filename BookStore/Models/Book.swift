struct Book {
    
    struct Chapter {
        
        let id: Int
        let title: String
        let timecode: Double
    }
    
    let id: Int
    let title: String
    let author: String
    let artwork: String
    let mediaUrl: String
    let duration: Double
    let chapters: [Chapter]
}

extension Book: Equatable {
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Book {
    
    static var sample = Self(
        id: 1,
        title: "Нація",
        author: "Марія Матіос",
        artwork: "https://4read.org/uploads/posts/2020-09/medium/1599634013_marya-nacya.jpg",
        mediaUrl: "https://dfbx.info/ua/1297/01%20-%20Nacija01.mp3",
        duration: 1800,
        chapters: [
            Chapter(id: 1, title: "Beginning", timecode: 0),
            Chapter(id: 2, title: "Middle", timecode: 900),
            Chapter(id: 3, title: "30 sec to end", timecode: 1770)
        ]
    )
}