import Foundation

struct Record: BaseRecord {
    let id: UUID
    let type: RecordType
    let content: String
    let date: Date
    let moodTag: MoodTag
    let location: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, content, date, moodTag, location
    }
}