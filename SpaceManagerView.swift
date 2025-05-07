import SwiftUI

// Sheet类型枚举
enum SpaceSheetType {
    case addSpace
    case parentSelector
    case none
}

struct SpaceManagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var spaces: [Space] = []
    @State private var selectedSpace: Space?
    @State private var expandedSpaces: Set<UUID> = []
    @State private var sheetType: SpaceSheetType = .none
    @State private var tempSelectedParent: Space? = nil
    @State private var tempSpaceType: SpaceType = .personal
    
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
                    VStack(spacing: 0) {
                        // 当前选择的空间
                        if let selectedSpace = selectedSpace {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("当前空间")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: getSpaceIcon(for: selectedSpace.type))
                                        .foregroundColor(getSpaceColor(for: selectedSpace.type))
                                    
                                    Text(getFullPath(for: selectedSpace))
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                        
                        // 空间列表
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("所有空间")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Button {
                                    sheetType = .addSpace
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("添加")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.bottom, 4)
                            
                            // 全部空间选项
                            Button {
                                // 选择"全部"空间
                                selectedSpace = Space(id: UUID(), name: "全部", type: .all)
                            } label: {
                                HStack {
                                    Image(systemName: getSpaceIcon(for: .all))
                                        .foregroundColor(getSpaceColor(for: .all))
                                    
                                    Text("全部")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedSpace?.type == .all {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            
                            Divider()
                            
                            // 分层级显示空间
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(spaces.filter { $0.parentId == nil }) { space in
                                    SpaceRowView(
                                        space: space,
                                        selectedSpace: $selectedSpace,
                                        expandedSpaces: $expandedSpaces,
                                        spaces: spaces,
                                        level: 0
                                    )
                                    
                                    if space.id != spaces.filter({ $0.parentId == nil }).last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 保存按钮
                        VStack {
                            Button {
                                // 保存所选空间，并返回
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
            .sheet(isPresented: Binding<Bool>(
                get: { sheetType != .none },
                set: { if !$0 { sheetType = .none } }
            )) {
                switch sheetType {
                case .addSpace:
                    AddSpaceView(spaces: $spaces, sheetType: $sheetType, 
                                 tempSelectedParent: $tempSelectedParent, 
                                 tempSpaceType: $tempSpaceType)
                case .parentSelector:
                    ParentSelectorView(
                        spaces: spaces,
                        selectedParent: $tempSelectedParent,
                        sheetType: $sheetType,
                        spaceType: tempSpaceType
                    )
                case .none:
                    EmptyView()
                }
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
    @Binding var sheetType: SpaceSheetType
    @Binding var tempSelectedParent: Space?
    @Binding var tempSpaceType: SpaceType
    
    @State private var spaceName: String = ""
    @State private var selectedType: SpaceType = .personal
    
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
                    .onChange(of: selectedType) { newValue in
                        tempSpaceType = newValue
                    }
                    
                    // 父空间选择
                    if selectedType != .work && selectedType != .family && selectedType != .personal {
                        Button {
                            sheetType = .parentSelector
                        } label: {
                            HStack {
                                Text("父空间")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(tempSelectedParent?.name ?? "请选择")
                                    .foregroundColor(tempSelectedParent != nil ? .blue : .gray)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
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
                    tempSelectedParent = nil
                    sheetType = .none
                }
            )
        }
    }
    
    // 表单验证
    private var isFormValid: Bool {
        !spaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (selectedType == .work || selectedType == .family || selectedType == .personal || tempSelectedParent != nil)
    }
    
    // 添加空间
    private func addSpace() {
        let newSpace = Space(
            id: UUID(),
            name: spaceName,
            type: selectedType,
            parentId: tempSelectedParent?.id
        )
        
        spaces.append(newSpace)
        tempSelectedParent = nil
        sheetType = .none
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
    @Binding var sheetType: SpaceSheetType
    let spaceType: SpaceType
    
    var body: some View {
        NavigationView {
            List {
                // 显示可选的父空间
                ForEach(spaces.filter { isValidParent($0) }) { space in
                    Button {
                        selectedParent = space
                        sheetType = .addSpace
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
            .navigationBarTitle("选择父空间", displayMode: .inline)
            .navigationBarItems(
                leading: Button("返回") {
                    sheetType = .addSpace
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