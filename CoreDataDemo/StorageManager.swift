//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by mac on 17.05.2022.
//


import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    func fetchData() -> [Task]? {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let task = try context.fetch(fetchRequest)
            return task
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func save(title: String) -> Task? {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return nil }
        task.title = title
        saveContext()
        return task
    }
    
    
    func edit(_ task: Task, newName: String) {
        task.title = newName
        saveContext()
    }
    
    func delete(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
    }
}
