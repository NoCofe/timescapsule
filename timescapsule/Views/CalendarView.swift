import SwiftUI

struct CalendarGrid: View {
    @ObservedObject var viewModel: TimeLineViewModel
    @State private var yearView = true
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if yearView {
                    YearGridView(
                        year: selectedYear,
                        summaries: viewModel.yearSummaries,
                        onSelectMonth: { month in
                            selectedMonth = month
                            yearView = false
                        }
                    )
                } else {
                    MonthGridView(
                        year: selectedYear,
                        month: selectedMonth,
                        summaries: viewModel.monthSummaries.filter {
                            let components = Calendar.current.dateComponents([.year, .month], from: $0.date)
                            return components.year == selectedYear && components.month == selectedMonth
                        },
                        onBackToYear: {
                            yearView = true
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct YearGridView: View {
    let year: Int
    let summaries: [DailySummary]
    let onSelectMonth: (Int) -> Void
    
    // 获取每种情绪的数量
    var moodCounts: [MoodTag: Int] {
        Dictionary(grouping: summaries, by: { $0.moodTag })
            .mapValues { $0.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("\(year) 年")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.black)
                }
            }
            
            // 情绪统计
            Text("\(moodCounts[.neutral, default: 0]) × 平静 + \(moodCounts[.happy, default: 0]) × 不错 + \(moodCounts[.sad, default: 0]) × 难过 = \(moodCounts[.excited, default: 0]) × 可爱日子")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 分割线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 10)
            
            // 月份展示
            ForEach(1...12, id: \.self) { month in
                MonthRowView(
                    year: year,
                    month: month,
                    summaries: summaries.filter {
                        Calendar.current.component(.month, from: $0.date) == month
                    },
                    onSelect: {
                        onSelectMonth(month)
                    }
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct MonthRowView: View {
    let year: Int
    let month: Int
    let summaries: [DailySummary]
    let onSelect: () -> Void
    
    // 获取月份名称
    var monthName: String {
        let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return month <= monthNames.count ? monthNames[month - 1] : ""
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(monthName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if month == Calendar.current.component(.month, from: Date()) {
                        Text("日日是好日。")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.black)
                    }
                }
                
                if summaries.isEmpty {
                    Text("暂无记录")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 5)
                } else {
                    // 日历网格视图预览
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                        ForEach(1...30, id: \.self) { day in
                            DayCell(day: day, hasRecord: hasDayRecord(day: day))
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func hasDayRecord(day: Int) -> Bool {
        summaries.contains { summary in
            let dayComponent = Calendar.current.component(.day, from: summary.date)
            return dayComponent == day
        }
    }
}

struct DayCell: View {
    let day: Int
    let hasRecord: Bool
    
    var body: some View {
        Group {
            if hasRecord {
                ZStack {
                    Rectangle()
                        .fill(Color(red: 0.05, green: 0.15, blue: 0.3))
                        .frame(width: 40, height: 40)
                }
            } else {
                if day == 27 {  // 示例中特殊高亮的日期
                    ZStack {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                            .offset(y: 16)
                    }
                } else {
                    Rectangle()
                        .strokeBorder(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.5))
                }
            }
        }
    }
}

struct MonthGridView: View {
    let year: Int
    let month: Int
    let summaries: [DailySummary]
    let onBackToYear: () -> Void
    
    // 获取月份的第一天是星期几
    var firstWeekday: Int {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        if let date = calendar.date(from: components) {
            return calendar.component(.weekday, from: date) - 1  // 星期日为1，我们需要0-6
        }
        return 0
    }
    
    // 获取月份的天数
    var daysInMonth: Int {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 30
    }
    
    // 获取月份名称
    var monthName: String {
        let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return month <= monthNames.count ? monthNames[month - 1] : ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: onBackToYear) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("\(year) 年")
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.black)
                }
            }
            
            Text("日日是好日。")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 星期标题
            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            
            // 日期网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 8) {
                // 填充第一天之前的空白
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }
                
                // 显示月份的天数
                ForEach(1...daysInMonth, id: \.self) { day in
                    DayCell(day: day, hasRecord: hasDayRecord(day: day))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
    
    func hasDayRecord(day: Int) -> Bool {
        summaries.contains { summary in
            let dayComponent = Calendar.current.component(.day, from: summary.date)
            return dayComponent == day
        }
    }
}

struct CalendarView: View {
    let summaries: [DailySummary]
    
    var body: some View {
        Text("日历视图")
    }
}