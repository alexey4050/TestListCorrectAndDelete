//
//  StorageManager.swift
//  TestListHWApp
//
//  Created by testing on 25.11.2023.
//

import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    private let context: NSManagedObjectContext
    private var taskList: [Task] = []
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TestListHWApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    func fetchData(completion: ([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            completion(taskList)
        } catch {
            print("Failed to fetch data:", error)
        }
    }
    
    func saveTask(_ taskName: String, completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = taskName
        completion(task)
        saveContext()
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        context.delete(task)
        saveContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateTask(_ newTask: Task) {
        taskList = taskList.map { task in
            if task.id == newTask.id {
            }
            return newTask
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
