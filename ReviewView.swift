import SwiftUI

struct ReviewView: View {
    @State private var currentViewMode: ViewMode = .week
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var weekDates: [Date] = []
    @State private var monthDates: [Date] = []
    @State private var selectedDayEntries: [ReviewEntry] = []
    
    // 心情数据
    private let moods: [String: (icon: String, color: Color)] = [
        "happy": ("🌞", .happyColor),
        "calm": ("⛅", .calmColor),
        "busy": ("🌪", .busyColor),
        "anxious": ("🌩", .anxiousColor),
        "sad": ("🌧", .sadColor),
        "neutral": ("❄️", .neutralColor)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部导航栏
                VStack(spacing: 0) {
                    HStack {
                        Text("回首")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Spacer()
                        
                        // 视图切换器
                        HStack(spacing: 0) {
                            Button {
                                withAnimation {
                                    currentViewMode = .week
                                }
                            } label: {
                                Text("周")
                                    .frame(width: 44, height: 32)
                                    .background(currentViewMode == .week ? Color.blue : Color.clear)
                                    .foregroundColor(currentViewMode == .week ? .white : .gray)
                            }
                            
                            Button {
                                withAnimation {
                                    currentViewMode = .month
                                }
                            } label: {
                                Text("月")
                                    .frame(width: 44, height: 32)
                                    .background(currentViewMode == .month ? Color.blue : Color.clear)
                                    .foregroundColor(currentViewMode == .month ? .white : .gray)
                            }
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    
                    // 月份选择器
                    HStack {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(formatMonth(currentDate))
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // 周视图
                        if currentViewMode == .week {
                            WeekView(
                                weekDates: weekDates,
                                selectedDate: $selectedDate,
                                moods: moods
                            )
                            
                            // 周摘要
                            WeekSummaryView()
                            
                        }
                        // 月视图
                        else {
                            MonthView(
                                currentDate: currentDate,
                                selectedDate: $selectedDate,
                                monthDates: monthDates,
                                moods: moods
                            )
                            
                            // 月度情绪统计
                            MonthSummaryView()
                        }
                        
                        // 选中日期的记录
                        if !selectedDayEntries.isEmpty {
                            SelectedDayView(
                                selectedDate: selectedDate,
                                entries: selectedDayEntries
                            )
                        } else {
                            NoEntriesView(date: selectedDate)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(Color(UIColor.systemGray6))
            }
            .onAppear {
                generateDates()
                loadEntries()
            }
            .onChange(of: currentDate) { _ in
                generateDates()
            }
            .onChange(of: selectedDate) { _ in
                loadSelectedDayEntries()
            }
        }
    }
    
    // 改变月份
    private func changeMonth(by amount: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: amount, to: currentDate) {
            currentDate = newDate
            
            // 如果是月视图，选定的日期也要移动到新的月份
            if currentViewMode == .month {
                // 选择新月份的第一天
                let components = calendar.dateComponents([.year, .month], from: newDate)
                if let firstDayOfMonth = calendar.date(from: components) {
                    selectedDate = firstDayOfMonth
                }
            }
        }
    }
    
    // 生成日期数据
    private func generateDates() {
        let calendar = Calendar.current
        
        // 生成周视图数据
        let weekday = calendar.component(.weekday, from: currentDate)
        let weekdayOffset = weekday > 1 ? weekday - 2 : 6  // 将周一作为每周第一天
        
        if let mondayOfWeek = calendar.date(byAdding: .day, value: -weekdayOffset, to: currentDate) {
            var dates: [Date] = []
            var currentDateInWeek = mondayOfWeek
            
            for _ in 0..<7 {
                dates.append(currentDateInWeek)
                currentDateInWeek = calendar.date(byAdding: .day, value: 1, to: currentDateInWeek)!
            }
            
            weekDates = dates
        }
        
        // 生成月视图数据
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        if let firstDayOfMonth = calendar.date(from: components) {
            // 找到第一天是周几
            let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
            let weekdayOffset = firstWeekday > 1 ? firstWeekday - 2 : 6  // 周一为0
            
            // 找到显示的第一天（上个月的部分）
            if let startDate = calendar.date(byAdding: .day, value: -weekdayOffset, to: firstDayOfMonth) {
                var dates: [Date] = []
                var currentDateInMonth = startDate
                
                // 生成42个日期框（6周）
                for _ in 0..<42 {
                    dates.append(currentDateInMonth)
                    currentDateInMonth = calendar.date(byAdding: .day, value: 1, to: currentDateInMonth)!
                }
                
                monthDates = dates
            }
        }
        
        // 如果尚未选择日期，则设置为当前日期
        if selectedDate == Date() {
            selectedDate = currentDate
        }
    }
    
    // 格式化月份显示
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
    
    // 加载当前周期的记录
    private func loadEntries() {
        // 实际应用中，应从数据存储中获取
        // 这里仅作为示例
        
        loadSelectedDayEntries()
    }
    
    // 加载选中日期的记录
    private func loadSelectedDayEntries() {
        // 模拟数据
        let calendar = Calendar.current
        
        // 获取今天的日期和选择的日期之间的差异
        let today = Date()
        let differenceInDays = calendar.dateComponents([.day], from: calendar.startOfDay(for: selectedDate), to: calendar.startOfDay(for: today)).day ?? 0
        
        if differenceInDays == 0 {
            // 如果选择的是今天
            selectedDayEntries = [
                ReviewEntry(id: UUID(), time: "08:32", content: "今天早上带孩子去了公园，天气很好，孩子非常开心。", mood: "happy"),
                ReviewEntry(id: UUID(), time: "12:15", content: "午饭做了孩子最爱吃的意面，他吃了两大碗，看着他的胃口这么好，我很欣慰。", mood: "happy")
            ]
        } else if differenceInDays == 1 {
            // 如果选择的是昨天
            selectedDayEntries = [
                ReviewEntry(id: UUID(), time: "19:30", content: "今天工作太忙了，几乎没时间喘息。会议一个接一个，感觉有点力不从心。", mood: "busy")
            ]
        } else if differenceInDays > 1 && differenceInDays < 15 {
            // 过去几天的随机数据
            let randomMoods = ["happy", "calm", "busy", "anxious", "sad", "neutral"]
            let count = Int.random(in: 0...3)
            var entries: [ReviewEntry] = []
            
            for i in 0..<count {
                let hour = Int.random(in: 8...20)
                let minute = Int.random(in: 0...59)
                let timeString = String(format: "%02d:%02d", hour, minute)
                let randomMood = randomMoods[Int.random(in: 0..<randomMoods.count)]
                
                entries.append(
                    ReviewEntry(
                        id: UUID(),
                        time: timeString,
                        content: "这是第\(i+1)条记录，这天的心情是\(moods[randomMood]?.icon ?? "")。",
                        mood: randomMood
                    )
                )
            }
            
            selectedDayEntries = entries
        } else {
            // 更久远的日子，可能没有记录
            selectedDayEntries = []
        }
    }
    
    // 视图模式
    enum ViewMode {
        case week, month
    }
}

// 周视图
struct WeekView: View {
    let weekDates: [Date]
    @Binding var selectedDate: Date
    let moods: [String: (icon: String, color: Color)]
    
    var body: some View {
        VStack(spacing: 12) {
            // 星期标题
            HStack {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 16)
            
            // 日期色块
            HStack(spacing: 8) {
                ForEach(weekDates.indices, id: \.self) { index in
                    let date = weekDates[index]
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    
                    Button {
                        selectedDate = date
                    } label: {
                        VStack {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(isSelected ? .white : .primary)
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(getMoodColor(for: date))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // 获取心情颜色
    private func getMoodColor(for date: Date) -> Color {
        // 实际应用中，应根据数据存储中的记录返回颜色
        // 这里仅作为示例，生成随机心情
        
        let moodKeys = Array(moods.keys)
        let day = Calendar.current.component(.day, from: date)
        let moodKey = moodKeys[day % moodKeys.count]
        
        return moods[moodKey]?.color ?? Color.gray
    }
}

// 周摘要视图
struct WeekSummaryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("本周摘要")
                .font(.headline)
                .padding(.bottom, 4)
            
            Text("这周你的情绪大多是积极的，有2天感到开心，3天平静，1天忙碌。总体来说是个不错的一周！")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// 月视图
struct MonthView: View {
    let currentDate: Date
    @Binding var selectedDate: Date
    let monthDates: [Date]
    let moods: [String: (icon: String, color: Color)]
    
    var body: some View {
        VStack(spacing: 12) {
            // 星期标题
            HStack {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 16)
            
            // 日历网格
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(monthDates.indices, id: \.self) { index in
                    let date = monthDates[index]
                    let isCurrentMonth = isInCurrentMonth(date)
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    
                    Button {
                        selectedDate = date
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(isCurrentMonth ? getMoodColor(for: date) : Color.gray.opacity(0.2))
                                .aspectRatio(1, contentMode: .fill)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                                )
                            
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isCurrentMonth ? .primary : .gray)
                            
                            // 指示点（表示有记录）
                            if hasEntries(for: date) && isCurrentMonth {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 4, height: 4)
                                    .offset(x: 8, y: 8)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // 判断日期是否在当前月
    private func isInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        let currentDateComponents = calendar.dateComponents([.year, .month], from: currentDate)
        
        return dateComponents.year == currentDateComponents.year && dateComponents.month == currentDateComponents.month
    }
    
    // 获取心情颜色
    private func getMoodColor(for date: Date) -> Color {
        // 实际应用中，应根据数据存储中的记录返回颜色
        let moodKeys = Array(moods.keys)
        let day = Calendar.current.component(.day, from: date)
        let moodKey = moodKeys[day % moodKeys.count]
        
        return moods[moodKey]?.color ?? Color.gray
    }
    
    // 判断是否有记录（示例）
    private func hasEntries(for date: Date) -> Bool {
        // 实际应用中，应根据数据存储中是否存在记录返回
        // 这里随机生成
        let day = Calendar.current.component(.day, from: date)
        return day % 3 == 0  // 每隔三天有记录
    }
}

// 月度情绪统计视图
struct MonthSummaryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("11月心情总结")
                .font(.headline)
                .padding(.bottom, 4)
            
            // 心情统计
            HStack(spacing: 20) {
                MoodCountView(icon: "🌞", count: 7, color: .happyColor)
                MoodCountView(icon: "⛅", count: 8, color: .calmColor)
                MoodCountView(icon: "🌪", count: 6, color: .busyColor)
                MoodCountView(icon: "🌩", count: 3, color: .anxiousColor)
                MoodCountView(icon: "🌧", count: 2, color: .sadColor)
            }
            
            Text("本月情绪整体积极，有15天处于开心或平静状态，相比上月情绪有所提升。")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// 心情统计项
struct MoodCountView: View {
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                
                Text(icon)
                    .font(.system(size: 16))
            }
            
            Text("\(count)天")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// 选中日期记录视图
struct SelectedDayView: View {
    let selectedDate: Date
    let entries: [ReviewEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatDate(selectedDate))
                    .font(.headline)
                
                Spacer()
                
                Text("查看全部")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 8)
            
            ForEach(entries) { entry in
                EntryRowView(entry: entry)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日，EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// 记录行视图
struct EntryRowView: View {
    let entry: ReviewEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 心情图标
            ZStack {
                Circle()
                    .fill(getMoodColor(entry.mood))
                    .frame(width: 32, height: 32)
                
                Text(getMoodIcon(entry.mood))
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(entry.time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    // 获取心情颜色
    private func getMoodColor(_ mood: String) -> Color {
        switch mood {
        case "happy": return .happyColor
        case "calm": return .calmColor
        case "busy": return .busyColor
        case "anxious": return .anxiousColor
        case "sad": return .sadColor
        default: return .neutralColor
        }
    }
    
    // 获取心情图标
    private func getMoodIcon(_ mood: String) -> String {
        switch mood {
        case "happy": return "🌞"
        case "calm": return "⛅"
        case "busy": return "🌪"
        case "anxious": return "🌩"
        case "sad": return "🌧"
        default: return "❄️"
        }
    }
}

// 无记录视图
struct NoEntriesView: View {
    let date: Date
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.bottom, 4)
            
            Text("没有找到记录")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("这一天你似乎没有记录任何内容")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// 数据模型
struct ReviewEntry: Identifiable {
    let id: UUID
    let time: String
    let content: String
    let mood: String
} 