import Foundation

struct MediaItem: Identifiable, Codable {
    let id: UUID
    var type: MediaType
    var url: String
    var thumbnailUrl: String?
    var duration: TimeInterval?
    var recordId: UUID
    var createdAt: Date
}

enum MediaType: String, Codable {
    case image, video, audio
} 