# 时光胶囊应用数据模型设计

## 核心数据模型

### 1. User (用户)
用户是应用的核心实体，保存用户的基本信息。

```swift
struct User: Identifiable, Codable {
    let id: UUID                  // 用户唯一标识
    var username: String          // 用户名
    var avatar: String?           // 头像URL
    var createdAt: Date           // 账号创建时间
    var recordDays: Int           // 记录天数
    var settings: UserSettings    // 用户设置
}

struct UserSettings: Codable {
    var notificationEnabled: Bool       // 通知开关
    var syncEnabled: Bool               // 数据同步开关
    var themeMode: ThemeMode            // 主题模式
    var privacyMode: PrivacyMode        // 隐私设置
}

enum ThemeMode: String, Codable {
    case light, dark, system
}

enum PrivacyMode: String, Codable {
    case public, friendsOnly, private
}
```

### 2. Space (空间)
空间是记录的组织结构，可以层级嵌套。

```swift
struct Space: Identifiable, Codable {
    let id: UUID                  // 空间唯一标识
    var name: String              // 空间名称
    var icon: String              // 空间图标
    var color: String             // 空间颜色
    var parentId: UUID?           // 父空间ID (可选，顶级空间为nil)
    var createdAt: Date           // 创建时间
    var order: Int                // 排序顺序
    var ownerId: UUID             // 所有者ID
}
```

### 3. Record (记录)
记录是用户创建的内容，包括文字、图片、语音等。

```swift
struct Record: Identifiable, Codable {
    let id: UUID                  // 记录唯一标识
    var type: RecordType          // 记录类型
    var content: String           // 文本内容
    var date: Date                // 创建日期
    var moodTag: MoodTag          // 心情标签
    var location: String?         // 位置信息
    var spaceId: UUID             // 所属空间ID
    var mediaItems: [MediaItem]   // 媒体内容
    var isFutureRecord: Bool      // 是否是写给未来的记录
    var futureDate: Date?         // 未来记录的目标日期
    var isUnlocked: Bool          // 未来记录是否已解锁
    var creatorId: UUID           // 创建者ID
}

enum RecordType: String, Codable {
    case text                     // 纯文本
    case audio                    // 包含语音
    case image                    // 包含图片
    case video                    // 包含视频
}

enum MoodTag: String, Codable {
    case happy = "开心"
    case calm = "平静"
    case busy = "忙碌"
    case anxious = "焦虑"
    case sad = "低落"
    case neutral = "冷漠"
}
```

### 4. MediaItem (媒体内容)
媒体内容是记录中包含的图片、视频、语音等非文本内容。

```swift
struct MediaItem: Identifiable, Codable {
    let id: UUID                  // 媒体内容唯一标识
    var type: MediaType           // 媒体类型
    var url: String               // 媒体URL
    var thumbnailUrl: String?     // 缩略图URL (仅用于图片和视频)
    var duration: TimeInterval?   // 持续时间 (仅用于音频和视频)
    var recordId: UUID            // 所属记录ID
    var createdAt: Date           // 创建时间
}

enum MediaType: String, Codable {
    case image, video, audio
}
```

### 5. DailySummary (日常摘要)
日常摘要是AI基于用户记录自动生成的每日情绪和活动总结。

```swift
struct DailySummary: Identifiable, Codable {
    let id: UUID                  // 摘要唯一标识
    var date: Date                // 摘要日期
    var summaryText: String       // 摘要文本
    var moodTag: MoodTag          // 主要情绪标签
    var recordIds: [UUID]         // 相关记录ID
    var userId: UUID              // 用户ID
    var generatedAt: Date         // 生成时间
}
```

## 数据关系

### 一对多关系
- User -> Space: 一个用户可以创建多个空间
- User -> Record: 一个用户可以创建多个记录
- Space -> Record: 一个空间可以包含多个记录
- Space -> Space: 一个父空间可以包含多个子空间
- Record -> MediaItem: 一个记录可以包含多个媒体项
- User -> DailySummary: 一个用户可以有多个日常摘要

### 多对多关系
- Record <-> Tag: 一个记录可以有多个标签，一个标签可以应用于多个记录

## 数据存储策略

### 本地存储
- 使用CoreData作为本地数据库
- 用户创建的所有记录先保存在本地数据库
- 图片、视频和音频文件保存在本地文件系统，数据库中只存储文件路径

### 云同步
- 使用CloudKit或自定义服务器进行云同步
- 支持增量同步以减少数据传输
- 媒体文件使用懒加载策略，仅在需要时从云端下载

## 数据迁移策略

每当应用升级导致数据模型变更时，需要实施数据迁移策略：

1. 使用CoreData的轻量级迁移处理简单变更
2. 对于复杂变更，实现自定义迁移逻辑
3. 保留旧版本数据的备份，确保迁移失败时可以恢复

## 示例JSON

### 记录实例
```json
{
  "id": "6D815B19-3154-4459-BBB9-22ABF4595666",
  "type": "image",
  "content": "今天带孩子去了公园，天气很好，孩子非常开心。",
  "date": "2023-11-15T08:32:00Z",
  "moodTag": "happy",
  "location": "中央公园",
  "spaceId": "A4B5C6D7-E8F9-0A1B-2C3D-4E5F6A7B8C9D",
  "mediaItems": [
    {
      "id": "F1E2D3C4-B5A6-9876-5432-1FEDCBA98765",
      "type": "image",
      "url": "file:///Users/username/Documents/photos/park_20231115.jpg",
      "thumbnailUrl": "file:///Users/username/Documents/photos/thumbnails/park_20231115_thumb.jpg",
      "recordId": "6D815B19-3154-4459-BBB9-22ABF4595666",
      "createdAt": "2023-11-15T08:32:00Z"
    }
  ],
  "isFutureRecord": false,
  "isUnlocked": true,
  "creatorId": "1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D"
}
```

### 日常摘要实例
```json
{
  "id": "ABCDEF12-3456-7890-ABCD-EF1234567890",
  "date": "2023-11-15T00:00:00Z",
  "summaryText": "今天是充满阳光的一天！你和孩子共度了愉快的时光，情绪稳定积极。家庭活动带来了满足感。",
  "moodTag": "happy",
  "recordIds": [
    "6D815B19-3154-4459-BBB9-22ABF4595666",
    "7E915B19-3154-4459-BBB9-22ABF4595667"
  ],
  "userId": "1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D",
  "generatedAt": "2023-11-15T23:30:00Z"
}
``` 