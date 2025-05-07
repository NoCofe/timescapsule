import SwiftUI

struct TimeLineView: View {
    @ObservedObject var viewModel: TimeLineViewModel
    @State private var selectedTimeRange: TimeRange = .day
    
    enum TimeRange {
        case day
        case week
        case month
        case year
    }
    
    var body: some View {
        VStack {
            Picker("时间范围", selection: $selectedTimeRange) {
                Text("日").tag(TimeRange.day)
                Text("周").tag(TimeRange.week)
                Text("月").tag(TimeRange.month)
                Text("年").tag(TimeRange.year)
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selectedTimeRange {
            case .day:
                DayView(records: viewModel.dayRecords)
            case .week:
                WeekView(summaries: viewModel.weekSummaries)
            case .month:
                MonthView(summaries: viewModel.monthSummaries)
            case .year:
                YearView(summaries: viewModel.yearSummaries)
            }
        }
        .navigationTitle("时光轴")
    }
}

struct DayView: View {
    let records: [Record]
    
    var body: some View {
        List(records) { record in
            RecordRow(record: record)
        }
    }
}

struct WeekView: View {
    let summaries: [DailySummary]
    
    var body: some View {
        List(summaries) { summary in
            VStack(alignment: .leading) {
                Text(summary.date, style: .date)
                Text(summary.summaryText)
                Text(summary.moodTag.rawValue)
            }
        }
    }
}

struct MonthView: View {
    let summaries: [DailySummary]
    
    var body: some View {
        CalendarView(summaries: summaries)
    }
}

struct YearView: View {
    let summaries: [DailySummary]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(1...12, id: \.self) { month in
                    MonthCard(month: month, summaries: summaries.filter { summary in
                        Calendar.current.component(.month, from: summary.date) == month
                    })
                }
            }
        }
    }
}

struct MonthCard: View {
    let month: Int
    let summaries: [DailySummary]
    
    var body: some View {
        VStack {
            Text(Calendar.current.monthSymbols[month-1])
            Text("\(summaries.count)条记录")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

class TimeLineViewModel: ObservableObject {
    @Published var dayRecords: [Record] = [] {
        didSet {
            saveRecords()
        }
    }
    @Published var weekSummaries: [DailySummary] = []
    @Published var monthSummaries: [DailySummary] = []
    @Published var yearSummaries: [DailySummary] = []
    
    private let recordsKey = "savedRecords"
    
    func updateRecords(_ records: [Record]) {
        dayRecords = records
        
        // 按周/月/年分组记录
        weekSummaries = groupRecordsByTimeRange(records: records, component: .weekOfYear)
        monthSummaries = groupRecordsByTimeRange(records: records, component: .month)
        yearSummaries = groupRecordsByTimeRange(records: records, component: .year)
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(dayRecords) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([Record].self, from: data) {
            // 确保没有重复的UUID
            var uniqueRecords: [Record] = []
            var idSet = Set<UUID>()
            
            for record in decoded {
                if !idSet.contains(record.id) {
                    idSet.insert(record.id)
                    uniqueRecords.append(record)
                } else {
                    // 创建一个新的Record副本，但使用新的UUID
                    let newRecord = Record(
                        id: UUID(), // 生成新的UUID
                        type: record.type,
                        content: record.content,
                        date: record.date,
                        moodTag: record.moodTag,
                        location: record.location
                    )
                    idSet.insert(newRecord.id)
                    uniqueRecords.append(newRecord)
                }
            }
            
            updateRecords(uniqueRecords)
        } else {
            // 创建一些示例数据
            let demoRecords = createDemoRecords()
            updateRecords(demoRecords)
        }
    }
    
    // 创建示例数据
    private func createDemoRecords() -> [Record] {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        return [
            Record(
                id: UUID(),
                type: .text,
                content: "今天是个好天气，心情很不错！",
                date: today,
                moodTag: .happy,
                location: "家里"
            ),
            Record(
                id: UUID(),
                type: .image,
                content: "出去玩拍的照片",
                date: today,
                moodTag: .excited,
                location: "公园"
            ),
            Record(
                id: UUID(),
                type: .text,
                content: "昨天工作很忙，有点累。",
                date: yesterday,
                moodTag: .tired,
                location: "办公室"
            )
        ]
    }
    
    private func groupRecordsByTimeRange(records: [Record], component: Calendar.Component) -> [DailySummary] {
        let grouped = Dictionary(grouping: records) { record -> DateComponents in
            Calendar.current.dateComponents([.year, component], from: record.date)
        }
        
        return grouped.map { (key, records) in
            let moodCounts = Dictionary(grouping: records, by: { $0.moodTag })
            let dominantMood = moodCounts.max(by: { $0.value.count < $1.value.count })?.key ?? .neutral
            
            return DailySummary(
                id: UUID(),
                date: Calendar.current.date(from: key) ?? Date(),
                summaryText: "\(records.count)条记录",
                moodTag: dominantMood
            )
        }
    }
}