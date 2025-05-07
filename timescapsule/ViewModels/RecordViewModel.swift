import Foundation

class RecordViewModel: ObservableObject {
    @Published var records: [any BaseRecord] = []
    @Published var dailySummaries: [DailySummary] = []
    private var textRecords: [TextRecord] = []
    private var audioRecords: [AudioRecord] = []
    private var imageRecords: [ImageRecord] = []
    private var videoRecords: [VideoRecord] = []
    
    func addRecord(_ record: any BaseRecord) {
        records.append(record)
        
        // 根据记录类型分类存储
        switch record {
        case let textRecord as TextRecord:
            textRecords.append(textRecord)
        case let audioRecord as AudioRecord:
            audioRecords.append(audioRecord)
        case let imageRecord as ImageRecord:
            imageRecords.append(imageRecord)
        case let videoRecord as VideoRecord:
            videoRecords.append(videoRecord)
        default:
            break
        }
        
        // 当记录达到3条时自动生成每日总结
        if records.count % 3 == 0 {
            Task {
                await generateDailySummary()
            }
        }
    }
    
    func generateDailySummary() async {
        do {
            let aiService = AIService()
            let summary = try await aiService.generateDailySummary(records: records)
            DispatchQueue.main.async {
                self.dailySummaries.append(summary)
            }
        } catch {
            print("生成每日总结失败: \(error)")
        }
    }
}