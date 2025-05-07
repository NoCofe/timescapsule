import Foundation

struct DailySummary: Identifiable, Codable {
    let id: UUID
    let date: Date
    let summaryText: String
    let moodTag: MoodTag
}