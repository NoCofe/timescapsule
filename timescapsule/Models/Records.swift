import Foundation

struct TextRecord: BaseRecord {
    var id: UUID
    var type: RecordType
    var content: String
    var date: Date
    var moodTag: MoodTag
    
    init(content: String, date: Date = Date(), moodTag: MoodTag = .neutral) {
        self.id = UUID()
        self.type = RecordType.text
        self.content = content
        self.date = date
        self.moodTag = moodTag
    }
}

struct AudioRecord: BaseRecord {
    var id: UUID
    var type: RecordType
    var content: String
    var date: Date
    var moodTag: MoodTag
    var duration: TimeInterval
    var audioUrl: URL
    
    init(content: String, audioUrl: URL, duration: TimeInterval, date: Date = Date(), moodTag: MoodTag = .neutral) {
        self.id = UUID()
        self.type = RecordType.audio
        self.content = content
        self.audioUrl = audioUrl
        self.duration = duration
        self.date = date
        self.moodTag = moodTag
    }
}

struct ImageRecord: BaseRecord {
    var id: UUID
    var type: RecordType
    var content: String
    var date: Date
    var moodTag: MoodTag
    var imageUrl: URL
    
    init(content: String, imageUrl: URL, date: Date = Date(), moodTag: MoodTag = .neutral) {
        self.id = UUID()
        self.type = RecordType.image
        self.content = content
        self.imageUrl = imageUrl
        self.date = date
        self.moodTag = moodTag
    }
}

struct VideoRecord: BaseRecord {
    var id: UUID
    var type: RecordType
    var content: String
    var date: Date
    var moodTag: MoodTag
    var videoUrl: URL
    let duration: TimeInterval
    let thumbnail: URL?
    
    init(content: String, videoUrl: URL, duration: TimeInterval, thumbnail: URL? = nil, date: Date = Date(), moodTag: MoodTag = .neutral) {
        self.id = UUID()
        self.type = RecordType.video
        self.content = content
        self.videoUrl = videoUrl
        self.duration = duration
        self.thumbnail = thumbnail
        self.date = date
        self.moodTag = moodTag
    }
}