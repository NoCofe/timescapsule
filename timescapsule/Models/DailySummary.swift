import Foundation

struct DailySummary: Identifiable, Codable {
    let id: UUID
    var date: Date
    var summaryText: String
    var moodTag: MoodTag
    var recordIds: [UUID]
    var userId: UUID
    var generatedAt: Date
}