import Foundation
import CoreData

// MARK: - Record适配器
class RecordAdapter {
    
    static func toRecord(from entity: RecordEntity) -> Record {
        return Record(
            id: entity.id ?? UUID(),
            type: RecordType(rawValue: entity.type ?? "text") ?? .text,
            content: entity.content ?? "",
            date: entity.date ?? Date(),
            moodTag: MoodTag(rawValue: entity.moodTag ?? "neutral") ?? .neutral,
            location: entity.location
        )
    }
    
    static func toEntity(from record: Record, in context: NSManagedObjectContext) -> RecordEntity {
        let entity: RecordEntity
        
        // 检查是否存在此记录
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingEntity = results.first {
                entity = existingEntity
            } else {
                entity = RecordEntity(context: context)
                entity.id = record.id
            }
        } catch {
            entity = RecordEntity(context: context)
            entity.id = record.id
        }
        
        // 更新属性
        entity.content = record.content
        entity.date = record.date
        entity.type = record.type.rawValue
        entity.moodTag = record.moodTag.rawValue
        entity.location = record.location
        
        return entity
    }
}

// MARK: - Space适配器
class SpaceAdapter {
    
    static func toEntity(from space: Space, in context: NSManagedObjectContext) -> SpaceEntity {
        let entity: SpaceEntity
        
        // 检查是否存在此空间
        let fetchRequest: NSFetchRequest<SpaceEntity> = SpaceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", space.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingEntity = results.first {
                entity = existingEntity
            } else {
                entity = SpaceEntity(context: context)
                entity.id = space.id
            }
        } catch {
            entity = SpaceEntity(context: context)
            entity.id = space.id
        }
        
        // 更新属性
        entity.name = space.name
        entity.icon = space.icon
        entity.color = space.color
        entity.createdAt = space.createdAt
        entity.order = Int32(space.order)
        
        return entity
    }
    
    static func toSpace(from entity: SpaceEntity) -> Space {
        return Space(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            icon: entity.icon ?? "",
            color: entity.color ?? "",
            parentId: entity.parentSpace?.id,
            createdAt: entity.createdAt ?? Date(),
            order: Int(entity.order),
            ownerId: entity.owner?.id ?? UUID()
        )
    }
}

// MARK: - MediaItem适配器
class MediaItemAdapter {
    
    static func toEntity(from mediaItem: MediaItem, in context: NSManagedObjectContext) -> MediaItemEntity {
        let entity: MediaItemEntity
        
        // 检查是否存在此媒体项
        let fetchRequest: NSFetchRequest<MediaItemEntity> = MediaItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", mediaItem.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingEntity = results.first {
                entity = existingEntity
            } else {
                entity = MediaItemEntity(context: context)
                entity.id = mediaItem.id
            }
        } catch {
            entity = MediaItemEntity(context: context)
            entity.id = mediaItem.id
        }
        
        // 更新属性
        entity.type = mediaItem.type.rawValue
        entity.url = mediaItem.url
        entity.thumbnailUrl = mediaItem.thumbnailUrl
        entity.duration = mediaItem.duration ?? 0
        entity.createdAt = mediaItem.createdAt
        
        return entity
    }
    
    static func toMediaItem(from entity: MediaItemEntity) -> MediaItem {
        return MediaItem(
            id: entity.id ?? UUID(),
            type: MediaType(rawValue: entity.type ?? "image") ?? .image,
            url: entity.url ?? "",
            thumbnailUrl: entity.thumbnailUrl,
            duration: entity.duration,
            recordId: entity.record?.id ?? UUID(),
            createdAt: entity.createdAt ?? Date()
        )
    }
}

// MARK: - DailySummary适配器
class DailySummaryAdapter {
    
    static func toEntity(from summary: DailySummary, in context: NSManagedObjectContext) -> DailySummaryEntity {
        let entity: DailySummaryEntity
        
        // 检查是否存在此摘要
        let fetchRequest: NSFetchRequest<DailySummaryEntity> = DailySummaryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", summary.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingEntity = results.first {
                entity = existingEntity
            } else {
                entity = DailySummaryEntity(context: context)
                entity.id = summary.id
            }
        } catch {
            entity = DailySummaryEntity(context: context)
            entity.id = summary.id
        }
        
        // 更新属性
        entity.date = summary.date
        entity.summaryText = summary.summaryText
        entity.moodTag = summary.moodTag.rawValue
        entity.generatedAt = summary.generatedAt
        
        return entity
    }
    
    static func toDailySummary(from entity: DailySummaryEntity) -> DailySummary {
        return DailySummary(
            id: entity.id ?? UUID(),
            date: entity.date ?? Date(),
            summaryText: entity.summaryText ?? "",
            moodTag: MoodTag(rawValue: entity.moodTag ?? "neutral") ?? .neutral,
            recordIds: (entity.records?.allObjects as? [RecordEntity])?.compactMap { $0.id } ?? [],
            userId: entity.user?.id ?? UUID(),
            generatedAt: entity.generatedAt ?? Date()
        )
    }
}

// MARK: - User适配器
class UserAdapter {
    
    static func toEntity(from user: AppUser, in context: NSManagedObjectContext) -> UserEntity {
        let entity: UserEntity
        
        // 检查是否存在此用户
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingEntity = results.first {
                entity = existingEntity
            } else {
                entity = UserEntity(context: context)
                entity.id = user.id
            }
        } catch {
            entity = UserEntity(context: context)
            entity.id = user.id
        }
        
        // 更新属性
        entity.username = user.username
        entity.avatar = user.avatar
        entity.createdAt = user.createdAt
        entity.recordDays = Int32(user.recordDays)
        
        // 创建或更新用户设置
        let settingsEntity = UserSettingsAdapter.toEntity(from: user.settings, in: context)
        entity.userSettings = settingsEntity
        
        return entity
    }
    
    static func toUser(from entity: UserEntity) -> AppUser {
        return AppUser(
            id: entity.id ?? UUID(),
            username: entity.username ?? "",
            avatar: entity.avatar,
            createdAt: entity.createdAt ?? Date(),
            recordDays: Int(entity.recordDays),
            settings: entity.userSettings != nil 
                ? UserSettingsAdapter.toUserSettings(from: entity.userSettings!) 
                : UserSettings(notificationEnabled: true, syncEnabled: true, themeMode: .system, privacyMode: .private)
        )
    }
}

// MARK: - UserSettings适配器
class UserSettingsAdapter {
    
    static func toEntity(from settings: UserSettings, in context: NSManagedObjectContext) -> UserSettingsEntity {
        let entity = UserSettingsEntity(context: context)
        entity.id = UUID()
        entity.notificationEnabled = settings.notificationEnabled
        entity.syncEnabled = settings.syncEnabled
        entity.themeMode = settings.themeMode.rawValue
        entity.privacyMode = settings.privacyMode.rawValue
        return entity
    }
    
    static func toUserSettings(from entity: UserSettingsEntity) -> UserSettings {
        return UserSettings(
            notificationEnabled: entity.notificationEnabled,
            syncEnabled: entity.syncEnabled,
            themeMode: ThemeMode(rawValue: entity.themeMode ?? "system") ?? .system,
            privacyMode: PrivacyMode(rawValue: entity.privacyMode ?? "private") ?? .private
        )
    }
} 