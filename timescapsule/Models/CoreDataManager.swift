import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {
        // 私有初始化方法，确保单例模式
    }
    
    // MARK: - Core Data 堆栈
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TimescapsuleModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("无法加载Core Data存储: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // 创建新的后台上下文
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Core Data 保存
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("保存上下文失败: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // 在后台上下文中保存
    func saveBackgroundContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("保存背景上下文失败: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - 数据操作辅助方法
    
    // 创建新实体
    func createEntity<T: NSManagedObject>(entityName: String) -> T {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: viewContext)!
        return T(entity: entity, insertInto: viewContext)
    }
    
    // 执行获取请求
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try viewContext.fetch(request)
        } catch {
            print("获取失败: \(error)")
            return []
        }
    }
    
    // 删除对象
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }
    
    // 根据谓词获取请求
    func fetchRequest<T: NSManagedObject>(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
} 