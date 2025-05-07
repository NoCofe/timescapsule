import Foundation

protocol BaseRecord: Identifiable, Codable {
    var id: UUID { get }
    var type: RecordType { get }
    var content: String { get }
    var date: Date { get }
    var moodTag: MoodTag { get }
}

enum RecordType: String, Codable {
    case text
    case audio
    case image
    case video
}

enum MoodTag: String, Codable {
    case happy = "开心"
    case neutral = "平静"
    case sad = "难过"
    case excited = "兴奋"
    case tired = "疲惫"
}