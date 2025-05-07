import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = TimeLineViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 标题栏
                HStack {
                    Button(action: {}) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Text("时间流")
                            .font(.headline)
                            .fontWeight(selectedTab == 0 ? .bold : .regular)
                            .foregroundColor(.white.opacity(selectedTab == 0 ? 1 : 0.7))
                            .onTapGesture { selectedTab = 0 }
                        
                        Text("时间格")
                            .font(.headline)
                            .fontWeight(selectedTab == 1 ? .bold : .regular)
                            .foregroundColor(.white.opacity(selectedTab == 1 ? 1 : 0.7))
                            .onTapGesture { selectedTab = 1 }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(red: 0.05, green: 0.15, blue: 0.3))
                
                // 主要内容区域
                if selectedTab == 0 {
                    TimelineStream(records: viewModel.dayRecords)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    CalendarGrid(viewModel: viewModel)
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .onAppear {
            viewModel.loadRecords()
            
            // 监听新记录添加的通知
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("newRecordAdded"),
                object: nil,
                queue: .main
            ) { notification in
                if let newRecord = notification.object as? Record {
                    var updatedRecords = viewModel.dayRecords
                    updatedRecords.append(newRecord)
                    viewModel.updateRecords(updatedRecords)
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.headline)
                    .padding(.vertical, 12)
                    .foregroundColor(isSelected ? .black : .gray)
                Rectangle()
                    .fill(isSelected ? Color.black : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct TimelineStream: View {
    let records: [Record]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 20) {
                if records.isEmpty {
                    EmptyTimelineView()
                        .frame(minHeight: 300)
                } else {
                    ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { date in
                        VStack(alignment: .leading, spacing: 15) {
                            Text(dateHeaderText(for: date))
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            ForEach(groupedRecords[date]!, id: \.id) { record in
                                RecordCard(record: record)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 添加底部间距
                    Spacer()
                        .frame(height: 20)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // 按日期分组记录
    var groupedRecords: [Date: [Record]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
        return grouped
    }
    
    // 日期标题展示
    func dateHeaderText(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今日"
        } else if calendar.isDateInYesterday(date) {
            return "昨日"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: date)
        }
    }
}

struct RecordCard: View {
    let record: Record
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // 记录类型图标
                Image(systemName: typeIcon(record.type))
                    .foregroundColor(typeColor(record.type))
                    .font(.system(size: 18))
                
                Text(recordTypeTitle(record.type))
                    .font(.headline)
                    .foregroundColor(typeColor(record.type))
                
                Spacer()
                
                Text(formattedTime(record.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // 记录内容区域
            recordContent
            
            // 底部标签区域
            if record.moodTag != .neutral {
                HStack {
                    Text(record.moodTag.rawValue)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(moodColor(record.moodTag))
                        .cornerRadius(10)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    var recordContent: some View {
        switch record.type {
        case .text:
            Text(record.content)
                .font(.body)
                .padding(.vertical, 5)
        
        case .audio:
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(.orange)
                    Text("语音记录")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 24))
                }
                .padding(.vertical, 5)
                
                Divider()
                
                Text(record.content)
                    .font(.body)
                    .padding(.vertical, 5)
            }
            
        case .image:
            VStack(alignment: .leading, spacing: 5) {
                // 这里会显示实际图片，当前使用占位符
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    )
                
                if !record.content.isEmpty {
                    Text(record.content)
                        .font(.body)
                        .padding(.top, 5)
                }
            }
            
        case .video:
            VStack(alignment: .leading, spacing: 5) {
                // 视频缩略图展示区
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(8)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                if !record.content.isEmpty {
                    Text(record.content)
                        .font(.body)
                        .padding(.top, 5)
                }
            }
        }
    }
    
    func recordTypeTitle(_ type: RecordType) -> String {
        switch type {
        case .text: return "文字记录"
        case .audio: return "语音记录"
        case .image: return "照片记录"
        case .video: return "视频记录"
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 M 月 d 日"
        return formatter.string(from: date)
    }
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func typeIcon(_ type: RecordType) -> String {
        switch type {
        case .text: return "text.bubble.fill"
        case .audio: return "mic.circle.fill"
        case .image: return "photo.circle.fill"
        case .video: return "video.circle.fill"
        }
    }
    
    func typeColor(_ type: RecordType) -> Color {
        switch type {
        case .text: return .blue
        case .audio: return .orange
        case .image: return .purple
        case .video: return .green
        }
    }
    
    func moodColor(_ mood: MoodTag) -> Color {
        switch mood {
        case .happy: return .green
        case .excited: return .pink
        case .neutral: return .blue
        case .sad: return .gray
        case .tired: return .brown
        }
    }
}

struct EmptyTimelineView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack {
                Text("我们的故事开始")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(formattedDate(Date()))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                Capsule()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Capsule().fill(Color.white))
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 M 月 d 日"
        return formatter.string(from: date)
    }
} 