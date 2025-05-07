import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddEntrySheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // 首页
                HomeView()
                    .tag(0)
                
                // 回首页
                ReviewView()
                    .tag(1)
                
                // 占位视图（中间凸起的添加按钮）
                Color.clear
                    .tag(2)
                
                // 未来页面
                FutureView()
                    .tag(3)
                
                // 我的页面
                ProfileView()
                    .tag(4)
            }
            .tabViewStyle(DefaultTabViewStyle())
            .ignoresSafeArea(edges: .bottom)
            
            // 自定义标签栏
            HStack(spacing: 0) {
                // 首页
                TabBarButton(
                    image: "house.fill",
                    text: "首页",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                // 回首
                TabBarButton(
                    image: "calendar",
                    text: "回首",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                // 添加按钮（中间凸起）
                AddButton {
                    showAddEntrySheet = true
                }
                .offset(y: -15)
                
                // 未来
                TabBarButton(
                    image: "sparkles",
                    text: "未来",
                    isSelected: selectedTab == 3
                ) {
                    selectedTab = 3
                }
                
                // 我的
                TabBarButton(
                    image: "person.fill",
                    text: "我的",
                    isSelected: selectedTab == 4
                ) {
                    selectedTab = 4
                }
            }
            .frame(height: 60)
            .background(
                Color.white
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: -1)
            )
        }
        .sheet(isPresented: $showAddEntrySheet) {
            AddEntryView()
        }
    }
}

// 标签栏按钮
struct TabBarButton: View {
    let image: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: image)
                    .font(.system(size: 24))
                
                Text(text)
                    .font(.system(size: 10))
            }
            .foregroundColor(isSelected ? Color.blue : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
}

// 添加按钮（中间凸起）
struct AddButton: View {
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
        }
    }
} 