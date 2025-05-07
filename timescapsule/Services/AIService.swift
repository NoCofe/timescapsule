import Foundation

class AIService {
    func transcribeVoice(audioData: Data) async throws -> String {
        // 模拟语音转文字结果
        let mockTexts = ["今天天气真好", "我完成了项目", "有点累了想休息"]
        return mockTexts.randomElement() ?? ""
    }
    
    func generateDailySummary(records: [any BaseRecord]) async throws -> DailySummary {
        // 模拟每日总结逻辑
        let summaryTexts = [
            "今天完成了3个任务，效率很高",
            "主要处理了项目A的需求",
            "休息时间充足，状态不错"
        ]
        return DailySummary(
            id: UUID(),
            date: Date(),
            summaryText: summaryTexts.randomElement() ?? "这是今天的总结",
            moodTag: .happy
        )
    }
    
    func analyzeMood(text: String) async throws -> MoodTag {
        // 模拟心情分析逻辑
        if text.contains("开心") || text.contains("完成") || text.contains("好") {
            return .happy
        } else if text.contains("累") || text.contains("休息") || text.contains("难") {
            return .tired
        }
        return .neutral
    }
}