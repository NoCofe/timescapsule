//
//  timescapsuleApp.swift
//  timescapsule
//
//  Created by jiangzhixuan on 2025/4/28.
//

import SwiftUI
import CoreData

@main
struct timescapsuleApp: App {
    // 在应用程序级别持有CoreDataManager的引用
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                .onAppear {
                    // 预加载CoreData堆栈
                    _ = coreDataManager.persistentContainer
                }
        }
    }
}
