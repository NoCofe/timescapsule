import Foundation

struct AppUser: Identifiable, Codable {
    let id: UUID
    var username: String
    var avatar: String?
    var createdAt: Date
    var recordDays: Int
    var settings: UserSettings
}

struct UserSettings: Codable {
    var notificationEnabled: Bool
    var syncEnabled: Bool
    var themeMode: ThemeMode
    var privacyMode: PrivacyMode
}

enum ThemeMode: String, Codable {
    case light, dark, system
}

enum PrivacyMode: String, Codable {
    case `public`, friendsOnly, `private`
} 