import SwiftUI

// 颜色扩展
extension Color {
    // 从十六进制创建颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // 应用中使用的常用颜色
    static let happyColor = Color(hex: "#FFD700") // 亮黄
    static let calmColor = Color(hex: "#87CEFA")  // 浅蓝
    static let busyColor = Color(hex: "#FFA07A")  // 橘粉
    static let anxiousColor = Color(hex: "#FF4500") // 橘红
    static let sadColor = Color(hex: "#708090")   // 灰蓝
    static let neutralColor = Color(hex: "#C0C0C0") // 银灰
}

// 快速访问命名颜色的便利函数
func moodColor(_ mood: String) -> Color {
    switch mood {
    case "happy": return .happyColor
    case "calm": return .calmColor
    case "busy": return .busyColor
    case "anxious": return .anxiousColor
    case "sad": return .sadColor
    case "neutral": return .neutralColor
    default: return Color.gray
    }
} 