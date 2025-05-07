import SwiftUI

struct HomeView: View {
    @State private var selectedSpace: String = "全部"
    @State private var entries: [EntryGroup] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    HStack {
                        Text("LifeSpace")
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        // 空间选择器
                        Button {
                            // 打开空间选择页面
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedSpace)
                                    .font(.system(size: 14))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // 时间轴内容
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(entries) { group in
                            EntryGroupView(group: group)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .background(Color(UIColor.systemGray6))
            .onAppear {
                // 加载数据
                loadEntries()
            }
        }
    }
    
    // 加载数据方法
    private func loadEntries() {
        // 模拟数据，实际应从数据存储中获取
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let todayEntries = [
            Entry(
                id: UUID(),
                time: formatter.date(from: "08:32") ?? Date(),
                content: "今天早上带孩子去了公园，天气很好，孩子非常开心。遇到了几个熟人，聊了一会儿，感觉心情舒畅。",
                images: [
                    "https://images.unsplash.com/photo-1596464716127-f2a82984de30",
                    "https://images.unsplash.com/photo-1588117305388-c2631a279f82"
                ],
                hasVoice: true,
                voiceDuration: 42,
                mood: "happy"
            ),
            Entry(
                id: UUID(),
                time: formatter.date(from: "12:15") ?? Date(),
                content: "午饭做了孩子最爱吃的意面，他吃了两大碗，看着他的胃口这么好，我很欣慰。",
                images: [
                    "https://images.unsplash.com/photo-1556761175-b413da4baf72"
                ],
                hasVoice: false,
                voiceDuration: 0,
                mood: "happy"
            )
        ]
        
        let yesterdayEntries = [
            Entry(
                id: UUID(),
                time: formatter.date(from: "19:30") ?? Date(),
                content: "今天工作太忙了，几乎没时间喘息。会议一个接一个，感觉有点力不从心。",
                images: [],
                hasVoice: true,
                voiceDuration: 84,
                mood: "busy"
            )
        ]
        
        entries = [
            EntryGroup(
                id: UUID(),
                title: "今天",
                entries: todayEntries,
                summary: DailySummary(
                    mood: "happy",
                    icon: "🌞",
                    content: "今天是充满阳光的一天！你和孩子共度了愉快的时光，情绪稳定积极。家庭活动带来了满足感。"
                )
            ),
            EntryGroup(
                id: UUID(),
                title: "昨天",
                entries: yesterdayEntries,
                summary: DailySummary(
                    mood: "busy",
                    icon: "🌪",
                    content: "工作压力较大，情绪偏向紧张和忙碌。建议今天给自己安排一些放松活动，平衡工作和生活。"
                )
            )
        ]
    }
}

// 日期分组视图
struct EntryGroupView: View {
    let group: EntryGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 日期标题
            Text(group.title)
                .font(.system(size: 18, weight: .semibold))
                .padding(.bottom, 4)
            
            // 条目列表
            ForEach(group.entries) { entry in
                EntryCardView(entry: entry)
            }
            
            // AI总结
            if let summary = group.summary {
                DailySummaryView(summary: summary)
            }
        }
    }
}

// 单条记录卡片视图
struct EntryCardView: View {
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 时间
            Text(formatTime(entry.time))
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            // 内容
            Text(entry.content)
                .font(.system(size: 16))
                .lineLimit(3)
                .padding(.bottom, 4)
            
            // 图片
            if !entry.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.images, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            }
                            .frame(width: 112, height: 112)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            
            // 语音播放器
            if entry.hasVoice {
                HStack {
                    Button {
                        // 播放语音
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                    }
                    
                    // 进度条
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 100, height: 4)
                    }
                    .cornerRadius(2)
                    
                    Text("\(entry.voiceDuration)秒")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 格式化时间
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// AI日总结视图
struct DailySummaryView: View {
    let summary: DailySummary
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 心情图标
            ZStack {
                Circle()
                    .fill(colorForMood(summary.mood))
                    .frame(width: 40, height: 40)
                
                Text(summary.icon)
                    .font(.system(size: 22))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("今日总结")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.blue.opacity(0.8))
                
                Text(summary.content)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    // 根据心情获取颜色
    private func colorForMood(_ mood: String) -> Color {
        switch mood {
        case "happy": return .happyColor
        case "calm": return .calmColor
        case "busy": return .busyColor
        case "anxious": return .anxiousColor
        case "sad": return .sadColor
        default: return .neutralColor
        }
    }
}

// 数据模型
struct Entry: Identifiable {
    let id: UUID
    let time: Date
    let content: String
    let images: [String]
    let hasVoice: Bool
    let voiceDuration: Int
    let mood: String
}

struct EntryGroup: Identifiable {
    let id: UUID
    let title: String
    let entries: [Entry]
    let summary: DailySummary?
}

struct DailySummary {
    let mood: String
    let icon: String
    let content: String
} 