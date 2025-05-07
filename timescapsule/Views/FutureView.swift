import SwiftUI

struct FutureView: View {
    @State private var futureMessages: [FutureMessage] = []
    @State private var showAddView = false
    @State private var selectedDate: Date?
    @State private var selectedTrigger: EventTrigger?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部标题
                Text("写给未来的自己")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 未来选择器
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("选择接收时间")
                                    .font(.headline)
                                
                                // 日期选择
                                Button {
                                    // 打开日期选择器
                                } label: {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.blue)
                                        
                                        Text("未来日期")
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text(selectedDate != nil ? formatDate(selectedDate!) : "选择日期")
                                            .foregroundColor(.blue)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 2)
                                }
                                .sheet(isPresented: $showAddView) {
                                    // 日期选择器视图
                                }
                                
                                Divider()
                                
                                // 事件触发
                                Button {
                                    // 打开事件触发选择
                                } label: {
                                    HStack {
                                        Image(systemName: "alarm")
                                            .foregroundColor(.purple)
                                        
                                        Text("事件触发")
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text(selectedTrigger != nil ? selectedTrigger!.name : "选择事件")
                                            .foregroundColor(.purple)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 2)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 添加按钮
                        Button {
                            showAddView = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("添加未来信息")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // 未来信息列表
                        VStack(alignment: .leading) {
                            Text("将在未来收到的信息")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            ForEach(futureMessages) { message in
                                FutureMessageCard(message: message)
                                    .padding(.horizontal)
                                    .padding(.bottom, 12)
                            }
                            
                            if futureMessages.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "arrow.up.forward.circle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.7))
                                        .padding(.bottom, 4)
                                    
                                    Text("还没有未来信息")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Text("点击上方按钮，给未来的自己写一条信息吧")
                                        .font(.subheadline)
                                        .foregroundColor(.gray.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding(.bottom, 20)
                }
                .background(Color(UIColor.systemGray6))
            }
            .onAppear {
                loadFutureMessages()
            }
            .sheet(isPresented: $showAddView) {
                AddRecordView()
            }
        }
    }
    
    // 加载未来信息
    private func loadFutureMessages() {
        // 实际应用中，应从数据存储中获取
        // 这里仅作为示例，加载示例数据
        
        futureMessages = [
            FutureMessage(
                id: UUID(),
                targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
                targetType: .date,
                title: "写给未来的自己",
                preview: "希望工作顺利，家庭和睦，未来一切安好...",
                mediaCount: 2,
                createdDaysAgo: 3,
                space: "个人"
            ),
            FutureMessage(
                id: UUID(),
                targetDate: Calendar.current.date(byAdding: .day, value: 60, to: Date())!,
                targetType: .event(name: "生日当天"),
                title: "生日快乐",
                preview: "祝自己生日快乐！希望这一年有所成长，能够更加坚强和独立...",
                mediaCount: 1,
                hasVoice: true,
                createdDaysAgo: 7,
                space: "个人"
            ),
            FutureMessage(
                id: UUID(),
                targetDate: Calendar.current.date(byAdding: .day, value: 90, to: Date())!,
                targetType: .event(name: "孩子生日"),
                title: "记录成长",
                preview: "记录下孩子的成长，希望在未来的日子里，我们能一起回顾这美好的时光...",
                mediaCount: 0,
                hasVideo: true,
                createdDaysAgo: 30,
                space: "家庭/孩子"
            )
        ]
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// 未来信息卡片视图
struct FutureMessageCard: View {
    let message: FutureMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 目标日期/事件 + 创建时间
            HStack {
                Text(targetText)
                    .font(.system(size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(targetBackground)
                    .foregroundColor(targetForeground)
                    .cornerRadius(12)
                
                Spacer()
                
                Text("\(message.createdDaysAgo)天前创建")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 预览内容
            Text(message.preview)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // 媒体信息 + 空间
            HStack {
                if message.mediaCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                        Text("\(message.mediaCount)张图片")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                if message.hasVoice {
                    HStack(spacing: 4) {
                        Image(systemName: "mic")
                            .foregroundColor(.gray)
                        Text("语音")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                if message.hasVideo {
                    HStack(spacing: 4) {
                        Image(systemName: "video")
                            .foregroundColor(.gray)
                        Text("视频")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .foregroundColor(.gray)
                    Text(message.space)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    // 目标日期/事件文本
    private var targetText: String {
        switch message.targetType {
        case .date:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: message.targetDate)
        case .event(let name):
            return name
        }
    }
    
    // 目标背景颜色
    private var targetBackground: Color {
        switch message.targetType {
        case .date:
            return Color.blue.opacity(0.2)
        case .event:
            return Color.purple.opacity(0.2)
        }
    }
    
    // 目标文字颜色
    private var targetForeground: Color {
        switch message.targetType {
        case .date:
            return Color.blue
        case .event:
            return Color.purple
        }
    }
}

// 日期选择器视图
struct DatePickerView: View {
    @Binding var selectedDate: Date?
    @Binding var isPresented: Bool
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择日期",
                    selection: $tempDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Button {
                    selectedDate = tempDate
                    isPresented = false
                } label: {
                    Text("确认")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationBarTitle("选择日期", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                }
            )
        }
    }
}

// 事件触发选择器视图
struct EventTriggerPickerView: View {
    @Binding var selectedTrigger: EventTrigger?
    @Binding var isPresented: Bool
    
    private let triggers: [EventTrigger] = [
        EventTrigger(id: "birthday", name: "生日当天"),
        EventTrigger(id: "anniversary", name: "结婚纪念日"),
        EventTrigger(id: "childBirthday", name: "孩子生日"),
        EventTrigger(id: "graduation", name: "毕业日"),
        EventTrigger(id: "newYear", name: "新年第一天")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(triggers) { trigger in
                    Button {
                        selectedTrigger = trigger
                        isPresented = false
                    } label: {
                        HStack {
                            Text(trigger.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedTrigger?.id == trigger.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("选择事件", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                }
            )
        }
    }
}

// 未来信息数据模型
struct FutureMessage: Identifiable {
    let id: UUID
    let targetDate: Date
    let targetType: TargetType
    let title: String
    let preview: String
    let mediaCount: Int
    var hasVoice: Bool = false
    var hasVideo: Bool = false
    let createdDaysAgo: Int
    let space: String
    
    enum TargetType {
        case date
        case event(name: String)
    }
}

// 事件触发数据模型
struct EventTrigger: Identifiable {
    let id: String
    let name: String
} 