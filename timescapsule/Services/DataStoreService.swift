import Foundation
import CoreData
import Combine

class DataStoreService {
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 记录操作
    
    func saveRecord(_ record: Record, in space: Space, by user: AppUser) {
        let context = coreDataManager.viewContext
        
        // 创建或更新记录实体
        let recordEntity = RecordAdapter.toEntity(from: record, in: context)
        
        // 获取空间实体
        let spaceEntity = SpaceAdapter.toEntity(from: space, in: context)
        
        // 获取用户实体
        let userEntity = UserAdapter.toEntity(from: user, in: context)
        
        // 建立关系
        recordEntity.space = spaceEntity
        recordEntity.creator = userEntity
        
        // 保存上下文
        coreDataManager.saveContext()
    }
    
    func fetchRecords(in spaceId: UUID? = nil, for userId: UUID, on date: Date? = nil) -> [Record] {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        // 用户条件
        predicates.append(NSPredicate(format: "creator.id == %@", userId as CVarArg))
        
        // 空间条件（如果指定）
        if let spaceId = spaceId {
            predicates.append(NSPredicate(format: "space.id == %@", spaceId as CVarArg))
        }
        
        // 日期条件（如果指定）
        if let date = date {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            predicates.append(NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let recordEntities = try context.fetch(fetchRequest)
            return recordEntities.map { RecordAdapter.toRecord(from: $0) }
        } catch {
            print("获取记录失败: \(error)")
            return []
        }
    }
    
    func deleteRecord(withId id: UUID) {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let recordToDelete = results.first {
                context.delete(recordToDelete)
                coreDataManager.saveContext()
            }
        } catch {
            print("删除记录失败: \(error)")
        }
    }
    
    // MARK: - 空间操作
    
    func saveSpace(_ space: Space) {
        let context = coreDataManager.viewContext
        
        // 创建或更新空间实体
        let spaceEntity = SpaceAdapter.toEntity(from: space, in: context)
        
        // 设置父空间关系（如果有）
        if let parentId = space.parentId {
            let fetchRequest: NSFetchRequest<SpaceEntity> = SpaceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", parentId as CVarArg)
            
            do {
                let results = try context.fetch(fetchRequest)
                spaceEntity.parentSpace = results.first
            } catch {
                print("获取父空间失败: \(error)")
            }
        }
        
        // 获取所有者
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", space.ownerId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            spaceEntity.owner = results.first
        } catch {
            print("获取空间所有者失败: \(error)")
        }
        
        // 保存上下文
        coreDataManager.saveContext()
    }
    
    func fetchSpaces(for userId: UUID, parentId: UUID? = nil) -> [Space] {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<SpaceEntity> = SpaceEntity.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        // 用户条件
        predicates.append(NSPredicate(format: "owner.id == %@", userId as CVarArg))
        
        // 父空间条件
        if let parentId = parentId {
            predicates.append(NSPredicate(format: "parentSpace.id == %@", parentId as CVarArg))
        } else {
            predicates.append(NSPredicate(format: "parentSpace == nil"))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do {
            let spaceEntities = try context.fetch(fetchRequest)
            return spaceEntities.map { SpaceAdapter.toSpace(from: $0) }
        } catch {
            print("获取空间失败: \(error)")
            return []
        }
    }
    
    func deleteSpace(withId id: UUID) {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<SpaceEntity> = SpaceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let spaceToDelete = results.first {
                context.delete(spaceToDelete)
                coreDataManager.saveContext()
            }
        } catch {
            print("删除空间失败: \(error)")
        }
    }
    
    // MARK: - 用户操作
    
    func saveUser(_ user: AppUser) {
        let context = coreDataManager.viewContext
        _ = UserAdapter.toEntity(from: user, in: context)
        coreDataManager.saveContext()
    }
    
    func fetchUser(withId id: UUID) -> AppUser? {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first.map { UserAdapter.toUser(from: $0) }
        } catch {
            print("获取用户失败: \(error)")
            return nil
        }
    }
    
    // MARK: - 日常摘要操作
    
    func saveDailySummary(_ summary: DailySummary) {
        let context = coreDataManager.viewContext
        
        // 创建或更新摘要实体
        let summaryEntity = DailySummaryAdapter.toEntity(from: summary, in: context)
        
        // 获取用户实体
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "id == %@", summary.userId as CVarArg)
        
        do {
            let userResults = try context.fetch(userFetchRequest)
            summaryEntity.user = userResults.first
        } catch {
            print("获取摘要用户失败: \(error)")
        }
        
        // 获取相关记录
        let recordsFetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        let recordIds = summary.recordIds.map { $0 as CVarArg }
        recordsFetchRequest.predicate = NSPredicate(format: "id IN %@", recordIds)
        
        do {
            let recordResults = try context.fetch(recordsFetchRequest)
            let recordsSet = NSSet(array: recordResults)
            summaryEntity.records = recordsSet
        } catch {
            print("获取摘要相关记录失败: \(error)")
        }
        
        // 保存上下文
        coreDataManager.saveContext()
    }
    
    func fetchDailySummaries(for userId: UUID, from startDate: Date, to endDate: Date) -> [DailySummary] {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<DailySummaryEntity> = DailySummaryEntity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "user.id == %@ AND date >= %@ AND date <= %@", 
                                           userId as CVarArg, 
                                           startDate as NSDate, 
                                           endDate as NSDate)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let summaryEntities = try context.fetch(fetchRequest)
            return summaryEntities.map { DailySummaryAdapter.toDailySummary(from: $0) }
        } catch {
            print("获取日常摘要失败: \(error)")
            return []
        }
    }
    
    // MARK: - 媒体项操作
    
    func addMediaItemToRecord(mediaItem: MediaItem, recordId: UUID) {
        let context = coreDataManager.viewContext
        
        // 创建媒体项实体
        let mediaItemEntity = MediaItemAdapter.toEntity(from: mediaItem, in: context)
        
        // 获取记录实体
        let recordFetchRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        recordFetchRequest.predicate = NSPredicate(format: "id == %@", recordId as CVarArg)
        
        do {
            let recordResults = try context.fetch(recordFetchRequest)
            if let recordEntity = recordResults.first {
                mediaItemEntity.record = recordEntity
                
                // 添加到记录的媒体项集合
                if recordEntity.mediaItems == nil {
                    recordEntity.mediaItems = NSSet(object: mediaItemEntity)
                } else {
                    let mediaItems = recordEntity.mediaItems!.mutableCopy() as! NSMutableSet
                    mediaItems.add(mediaItemEntity)
                    recordEntity.mediaItems = mediaItems
                }
                
                coreDataManager.saveContext()
            }
        } catch {
            print("添加媒体项失败: \(error)")
        }
    }
    
    func fetchMediaItems(for recordId: UUID) -> [MediaItem] {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<MediaItemEntity> = MediaItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "record.id == %@", recordId as CVarArg)
        
        do {
            let mediaItemEntities = try context.fetch(fetchRequest)
            return mediaItemEntities.map { MediaItemAdapter.toMediaItem(from: $0) }
        } catch {
            print("获取媒体项失败: \(error)")
            return []
        }
    }
    
    func deleteMediaItem(withId id: UUID) {
        let context = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<MediaItemEntity> = MediaItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let mediaItemToDelete = results.first {
                context.delete(mediaItemToDelete)
                coreDataManager.saveContext()
            }
        } catch {
            print("删除媒体项失败: \(error)")
        }
    }
} 