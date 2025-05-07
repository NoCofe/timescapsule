import SwiftUI

struct ProfileView: View {
    @State private var showLogoutAlert = false
    @State private var user = User(
        name: "李小明",
        avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
        recordDays: 42
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部标题
                Text("我的")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 用户信息卡片
                        HStack(spacing: 16) {
                            // 头像
                            AsyncImage(url: URL(string: user.avatar)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 64, height: 64)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            // 用户信息
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Text("已记录\(user.recordDays)天")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 设置列表
                        VStack(spacing: 0) {
                            // 设置组 1
                            SettingsSectionView(settings: [
                                Setting(
                                    icon: "bell.fill",
                                    iconColor: .blue,
                                    title: "通知设置",
                                    destination: AnyView(NotificationSettingsView())
                                ),
                                Setting(
                                    icon: "icloud.fill",
                                    iconColor: .blue,
                                    title: "数据同步",
                                    destination: AnyView(DataSyncSettingsView())
                                ),
                                Setting(
                                    icon: "lock.fill",
                                    iconColor: .blue,
                                    title: "隐私设置",
                                    destination: AnyView(PrivacySettingsView())
                                ),
                                Setting(
                                    icon: "paintbrush.fill",
                                    iconColor: .blue,
                                    title: "主题与外观",
                                    destination: AnyView(ThemeSettingsView())
                                )
                            ])
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            // 设置组 2
                            SettingsSectionView(settings: [
                                Setting(
                                    icon: "questionmark.circle.fill",
                                    iconColor: .blue,
                                    title: "帮助中心",
                                    destination: AnyView(HelpCenterView())
                                ),
                                Setting(
                                    icon: "info.circle.fill",
                                    iconColor: .blue,
                                    title: "关于我们",
                                    destination: AnyView(AboutUsView())
                                )
                            ])
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        .padding(.horizontal)
                        
                        // 退出登录按钮
                        Button {
                            showLogoutAlert = true
                        } label: {
                            Text("退出登录")
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        .alert(isPresented: $showLogoutAlert) {
                            Alert(
                                title: Text("确认退出登录"),
                                message: Text("退出后需要重新登录才能使用"),
                                primaryButton: .destructive(Text("退出")) {
                                    // 执行退出登录操作
                                    logout()
                                },
                                secondaryButton: .cancel(Text("取消"))
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(Color(UIColor.systemGray6))
            }
        }
    }
    
    // 退出登录
    private func logout() {
        // 实际应用中，应清除用户状态并返回登录页
        print("用户已退出登录")
    }
}

// 设置组视图
struct SettingsSectionView: View {
    let settings: [Setting]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(settings) { setting in
                NavigationLink(destination: setting.destination) {
                    HStack(spacing: 12) {
                        Image(systemName: setting.icon)
                            .font(.system(size: 18))
                            .foregroundColor(setting.iconColor)
                            .frame(width: 24, height: 24)
                            .padding(.leading, 16)
                        
                        Text(setting.title)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.trailing, 16)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
    }
}

// 设置项模型
struct Setting: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let destination: AnyView
}

// 用户模型
struct User {
    let name: String
    let avatar: String
    let recordDays: Int
}

// 设置页面示例
struct NotificationSettingsView: View {
    @State private var enablePushNotifications = true
    @State private var enableSummaryNotifications = true
    @State private var enableReminderNotifications = false
    
    var body: some View {
        Form {
            Section(header: Text("通知设置")) {
                Toggle("推送通知", isOn: $enablePushNotifications)
                Toggle("每日总结通知", isOn: $enableSummaryNotifications)
                Toggle("记录提醒", isOn: $enableReminderNotifications)
            }
            
            Section(header: Text("提醒时间")) {
                if enableReminderNotifications {
                    DatePicker("每日提醒时间", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle("通知设置")
    }
}

struct DataSyncSettingsView: View {
    @State private var enableAutoSync = true
    @State private var syncWifiOnly = true
    
    var body: some View {
        Form {
            Section(header: Text("同步设置")) {
                Toggle("自动同步", isOn: $enableAutoSync)
                Toggle("仅在WiFi下同步", isOn: $syncWifiOnly)
            }
            
            Section {
                Button {
                    // 手动同步数据
                } label: {
                    HStack {
                        Text("立即同步")
                        Spacer()
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                Button {
                    // 清除本地缓存
                } label: {
                    HStack {
                        Text("清除本地缓存")
                            .foregroundColor(.red)
                        Spacer()
                        Text("23.5MB")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("数据同步")
    }
}

struct PrivacySettingsView: View {
    @State private var enableBiometricAuth = true
    @State private var enableLocationServices = false
    @State private var passcodeEnabled = false
    
    var body: some View {
        Form {
            Section(header: Text("安全设置")) {
                Toggle("使用Face ID / Touch ID", isOn: $enableBiometricAuth)
                Toggle("启用密码锁", isOn: $passcodeEnabled)
                
                if passcodeEnabled {
                    Button("修改密码") {
                        // 显示修改密码界面
                    }
                }
            }
            
            Section(header: Text("权限")) {
                Toggle("位置服务", isOn: $enableLocationServices)
                
                NavigationLink("管理权限设置") {
                    // 权限管理页面
                    Text("权限管理页面")
                }
            }
            
            Section {
                Button("导出我的数据") {
                    // 导出数据功能
                }
                
                Button("删除我的账户") {
                    // 删除账户功能
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("隐私设置")
    }
}

struct ThemeSettingsView: View {
    @State private var selectedTheme = 0
    @State private var useDarkMode = false
    @State private var useSystemTheme = true
    
    private let themes = ["默认", "轻松", "专注", "夜间"]
    
    var body: some View {
        Form {
            Section(header: Text("主题选择")) {
                Picker("主题", selection: $selectedTheme) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        Text(themes[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 8)
                
                Toggle("使用系统外观", isOn: $useSystemTheme)
                
                if !useSystemTheme {
                    Toggle("深色模式", isOn: $useDarkMode)
                        .disabled(useSystemTheme)
                }
            }
            
            Section(header: Text("字体大小")) {
                Slider(value: .constant(0.5), in: 0...1, step: 0.1) {
                    Text("字体大小")
                } minimumValueLabel: {
                    Text("小")
                        .font(.caption)
                } maximumValueLabel: {
                    Text("大")
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("主题与外观")
    }
}

struct HelpCenterView: View {
    var body: some View {
        List {
            Section(header: Text("常见问题")) {
                NavigationLink("如何使用时间胶囊？") {
                    Text("使用教程内容")
                }
                NavigationLink("如何恢复已删除的记录？") {
                    Text("恢复教程内容")
                }
                NavigationLink("如何设置未来信息？") {
                    Text("未来信息教程内容")
                }
                NavigationLink("无法同步怎么办？") {
                    Text("同步问题解决方案")
                }
            }
            
            Section(header: Text("联系我们")) {
                Button {
                    // 反馈问题
                } label: {
                    HStack {
                        Text("反馈问题")
                        Spacer()
                        Image(systemName: "envelope")
                    }
                }
                
                Button {
                    // 联系客服
                } label: {
                    HStack {
                        Text("联系客服")
                        Spacer()
                        Image(systemName: "bubble.left.and.bubble.right")
                    }
                }
            }
        }
        .navigationTitle("帮助中心")
    }
}

struct AboutUsView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image("app_icon") // 替换为实际的应用图标
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(16)
                        .padding(.top, 20)
                    
                    Text("时光胶囊")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0 (1)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
                .background(Color.clear)
            }
            
            Section(header: Text("法律信息")) {
                NavigationLink("用户协议") {
                    Text("用户协议内容")
                }
                
                NavigationLink("隐私政策") {
                    Text("隐私政策内容")
                }
                
                NavigationLink("开源许可") {
                    Text("开源许可内容")
                }
            }
            
            Section {
                HStack {
                    Text("开发者")
                    Spacer()
                    Text("时光团队")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("版权所有")
                    Spacer()
                    Text("© 2023 时光团队")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("关于我们")
    }
} 