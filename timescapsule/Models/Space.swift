import Foundation

struct Space: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var parentId: UUID?
    var createdAt: Date
    var order: Int
    var ownerId: UUID
} 