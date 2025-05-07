import SwiftUI

struct SpaceManagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var spaces: [Space] = []
    @State private var selectedSpace: Space?
    @State private var expandedSpaces: Set<UUID> = []
    @State private var showAddSpaceSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部导航
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("返回")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("选择空间")
                        .font(.headline)
                    
                    Spacer()
                    
                    // 占位，保持标题居中
                    Button {
                    } label: {
                        Text("")
                            .frame(width: 50)
                    }
                    .opacity(0)
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 当前选择的空间
                        if let selected = selectedSpace {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("当前空间")
                                    .font(.headline)
                                    .foregroundColor(.blue.opacity(0.8))
                                
                                HStack {
                                    Image(systemName: getSpaceIcon(for: selected.type))
                                        .foregroundColor(getSpaceColor(for: selected.type))
                                    
                                    Text(getFullPath(for: selected))
                                        .fontWeight(.medium)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                        
                        // 空间列表
                        VStack(alignment: .leading, spacing: 0) {
                            // 全部空间选项
                            SpaceRowView(
                                space: Space(id: UUID(), name: "全部", type: .all),
                                selectedSpace: $selectedSpace,
                                expandedSpaces: $expandedSpaces,
                                spaces: spaces,
                                level: 0
                            )
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(selectedSpace?.type == .all ? Color.gray.opacity(0.1) : Color.clear)
                            
                            Divider()
                            
                            // 根空间列表
                            ForEach(spaces.filter { $0.parentId == nil && $0.type != .all }) { space in
                                SpaceRowView(
                                    space: space,
                                    selectedSpace: $selectedSpace,
                                    expandedSpaces: $expandedSpaces,
                                    spaces: spaces,
                                    level: 0
                                )
                                
                                Divider()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // 添加新空间按钮
                        Button {
                            showAddSpaceSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("添加新空间")
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        Spacer()
                        
                        // 底部按钮
                        HStack(spacing: 16) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("取消")
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            
                            Button {
                                // 保存选择的空间并返回
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("保存")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(selectedSpace == nil)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
                .background(Color(UIColor.systemGray6))
            }
            .sheet(isPresented: $showAddSpaceSheet) {
                AddSpaceView(spaces: $spaces)
            }
            .onAppear {
                loadSpaces()
            }
        }
    }
    
    // 获取空间图标
    private func getSpaceIcon(for type: SpaceType) -> String {
        switch type {
        case .all:
            return "tray.full.fill"
        case .work:
            return "briefcase.fill"
        case .family:
            return "house.fill"
        case .personal:
            return "person.fill"
        case .child:
            return "figure.child"
        case .partner:
            return "person.2.fill"
        case .parent:
            return "figure.2.and.child.holdinghands"
        }
    }
    
    // 获取空间颜色
    private func getSpaceColor(for type: SpaceType) -> Color {
        switch type {
        case .all:
            return .yellow
        case .work:
            return .blue
        case .family:
            return .green
        case .personal:
            return .purple
        case .child:
            return .blue
        case .partner:
            return .green
        case .parent:
            return .purple
        }
    }
    
    // 获取完整空间路径
    private func getFullPath(for space: Space) -> String {
        var path = space.name
        var parentId = space.parentId
        
        while let parent = parentId {
            if let parentSpace = spaces.first(where: { $0.id == parent }) {
                path = "\(parentSpace.name) / \(path)"
                parentId = parentSpace.parentId
            } else {
                break
            }
        }
        
        return path
    }
    
    // 加载空间数据
    private func loadSpaces() {
        // 模拟空间数据，实际应用中应从数据存储中获取
        let familyId = UUID()
        
        spaces = [
            Space(id: UUID(), name: "工作", type: .work),
            Space(id: familyId, name: "家庭", type: .family),
            Space(id: UUID(), name: "孩子", type: .child, parentId: familyId),
            Space(id: UUID(), name: "伴侣", type: .partner, parentId: familyId),
            Space(id: UUID(), name: "父母", type: .parent, parentId: familyId),
            Space(id: UUID(), name: "个人", type: .personal)
        ]
        
        // 默认选择"全部"空间
        selectedSpace = Space(id: UUID(), name: "全部", type: .all)
    }
}

// 空间行视图
struct SpaceRowView: View {
    let space: Space
    @Binding var selectedSpace: Space?
    @Binding var expandedSpaces: Set<UUID>
    let spaces: [Space]
    let level: Int
    
    private var childSpaces: [Space] {
        spaces.filter { $0.parentId == space.id }
    }
    
    private var isExpanded: Bool {
        expandedSpaces.contains(space.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 空间行
            HStack {
                // 缩进处理
                if level > 0 {
                    ForEach(0..<level, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 16)
                    }
                }
                
                // 图标
                Image(systemName: getSpaceIcon(for: space.type))
                    .foregroundColor(getSpaceColor(for: space.type))
                
                // 名称
                Text(space.name)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 展开/折叠指示器（如果有子空间）
                if !childSpaces.isEmpty {
                    Button {
                        toggleExpand()
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
            .padding(.horizontal, level > 0 ? 0 : 16)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .onTapGesture {
                selectSpace()
            }
            
            // 子空间（如果展开）
            if isExpanded {
                ForEach(childSpaces) { childSpace in
                    SpaceRowView(
                        space: childSpace,
                        selectedSpace: $selectedSpace,
                        expandedSpaces: $expandedSpaces,
                        spaces: spaces,
                        level: level + 1
                    )
                    .padding(.horizontal, level > 0 ? 0 : 16)
                    
                    if childSpace.id != childSpaces.last?.id {
                        Divider()
                            .padding(.leading, CGFloat(level + 1) * 16 + 16)
                    }
                }
            }
        }
    }
    
    // 获取空间图标
    private func getSpaceIcon(for type: SpaceType) -> String {
        switch type {
        case .all:
            return "tray.full.fill"
        case .work:
            return "briefcase.fill"
        case .family:
            return "house.fill"
        case .personal:
            return "person.fill"
        case .child:
            return "figure.child"
        case .partner:
            return "person.2.fill"
        case .parent:
            return "figure.2.and.child.holdinghands"
        }
    }
    
    // 获取空间颜色
    private func getSpaceColor(for type: SpaceType) -> Color {
        switch type {
        case .all:
            return .yellow
        case .work:
            return .blue
        case .family:
            return .green
        case .personal:
            return .purple
        case .child:
            return .blue
        case .partner:
            return .green
        case .parent:
            return .purple
        }
    }
    
    // 切换展开/折叠状态
    private func toggleExpand() {
        if expandedSpaces.contains(space.id) {
            expandedSpaces.remove(space.id)
        } else {
            expandedSpaces.insert(space.id)
        }
    }
    
    // 选择当前空间
    private func selectSpace() {
        selectedSpace = space
        
        // 如果有子空间，则切换展开状态
        if !childSpaces.isEmpty {
            toggleExpand()
        }
    }
    
    // 判断是否选中
    private var isSelected: Bool {
        selectedSpace?.id == space.id
    }
}

// 添加空间视图
struct AddSpaceView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var spaces: [Space]
    
    @State private var spaceName: String = ""
    @State private var selectedType: SpaceType = .personal
    @State private var selectedParent: Space? = nil
    @State private var showParentSelector = false
    
    // 可用的空间类型
    private let spaceTypes: [SpaceType] = [.work, .family, .personal, .child, .partner, .parent]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("空间信息")) {
                    TextField("空间名称", text: $spaceName)
                    
                    // 空间类型选择
                    Picker("空间类型", selection: $selectedType) {
                        ForEach(spaceTypes, id: \.self) { type in
                            HStack {
                                Image(systemName: getSpaceIcon(for: type))
                                    .foregroundColor(getSpaceColor(for: type))
                                Text(getSpaceTypeName(type))
                            }
                            .tag(type)
                        }
                    }
                    
                    // 父空间选择
                    if selectedType != .work && selectedType != .family && selectedType != .personal {
                        Button {
                            showParentSelector = true
                        } label: {
                            HStack {
                                Text("父空间")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(selectedParent?.name ?? "请选择")
                                    .foregroundColor(selectedParent != nil ? .blue : .gray)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $showParentSelector) {
                            ParentSelectorView(
                                spaces: spaces,
                                selectedParent: $selectedParent,
                                spaceType: selectedType
                            )
                        }
                    }
                }
                
                Section {
                    Button {
                        addSpace()
                    } label: {
                        Text("添加空间")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationBarTitle("添加新空间", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // 表单验证
    private var isFormValid: Bool {
        !spaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (selectedType == .work || selectedType == .family || selectedType == .personal || selectedParent != nil)
    }
    
    // 添加空间
    private func addSpace() {
        let newSpace = Space(
            id: UUID(),
            name: spaceName,
            type: selectedType,
            parentId: selectedParent?.id
        )
        
        spaces.append(newSpace)
        presentationMode.wrappedValue.dismiss()
    }
    
    // 获取空间类型名称
    private func getSpaceTypeName(_ type: SpaceType) -> String {
        switch type {
        case .all:
            return "全部"
        case .work:
            return "工作"
        case .family:
            return "家庭"
        case .personal:
            return "个人"
        case .child:
            return "孩子"
        case .partner:
            return "伴侣"
        case .parent:
            return "父母"
        }
    }
    
    // 获取空间图标
    private func getSpaceIcon(for type: SpaceType) -> String {
        switch type {
        case .all:
            return "tray.full.fill"
        case .work:
            return "briefcase.fill"
        case .family:
            return "house.fill"
        case .personal:
            return "person.fill"
        case .child:
            return "figure.child"
        case .partner:
            return "person.2.fill"
        case .parent:
            return "figure.2.and.child.holdinghands"
        }
    }
    
    // 获取空间颜色
    private func getSpaceColor(for type: SpaceType) -> Color {
        switch type {
        case .all:
            return .yellow
        case .work:
            return .blue
        case .family:
            return .green
        case .personal:
            return .purple
        case .child:
            return .blue
        case .partner:
            return .green
        case .parent:
            return .purple
        }
    }
}

// 父空间选择器视图
struct ParentSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    let spaces: [Space]
    @Binding var selectedParent: Space?
    let spaceType: SpaceType
    
    var body: some View {
        NavigationView {
            List {
                // 显示可选的父空间
                ForEach(spaces.filter { isValidParent($0) }) { space in
                    Button {
                        selectedParent = space
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: getSpaceIcon(for: space.type))
                                .foregroundColor(getSpaceColor(for: space.type))
                            
                            Text(space.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedParent?.id == space.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("选择父空间", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // 判断是否可以作为父空间
    private func isValidParent(_ space: Space) -> Bool {
        // 子空间的父空间必须是家庭
        if spaceType == .child || spaceType == .partner || spaceType == .parent {
            return space.type == .family
        }
        
        return false
    }
    
    // 获取空间图标
    private func getSpaceIcon(for type: SpaceType) -> String {
        switch type {
        case .all:
            return "tray.full.fill"
        case .work:
            return "briefcase.fill"
        case .family:
            return "house.fill"
        case .personal:
            return "person.fill"
        case .child:
            return "figure.child"
        case .partner:
            return "person.2.fill"
        case .parent:
            return "figure.2.and.child.holdinghands"
        }
    }
    
    // 获取空间颜色
    private func getSpaceColor(for type: SpaceType) -> Color {
        switch type {
        case .all:
            return .yellow
        case .work:
            return .blue
        case .family:
            return .green
        case .personal:
            return .purple
        case .child:
            return .blue
        case .partner:
            return .green
        case .parent:
            return .purple
        }
    }
}

// 空间数据模型
struct Space: Identifiable {
    let id: UUID
    let name: String
    let type: SpaceType
    var parentId: UUID? = nil
}

// 空间类型枚举
enum SpaceType: Hashable {
    case all
    case work
    case family
    case personal
    case child
    case partner
    case parent
} 