//
//  DataManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import CoreData
import Foundation

class DataManager: NSObject {
    required init?(name: String?) throws {
        super.init()
        managedObjectModel = NSManagedObjectModel(contentsOfURL: NSBundle.mainBundle().URLForResource("WeCenterMobile", withExtension: "momd")!)
        if managedObjectModel == nil {
            return nil
        }
        if name != nil {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
            let url = directory.URLByAppendingPathComponent(name! + ".sqlite")
            do {
                try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            } catch var error as NSError {
                let dict = NSMutableDictionary()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data."
                dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
                dict[NSUnderlyingErrorKey] = error
                error = NSError(
                    domain: NetworkManager.defaultManager!.website,
                    code: NetworkManager.defaultManager!.internalErrorCode.integerValue,
                    userInfo: (dict as NSDictionary as! [NSObject : AnyObject]))
                throw error
            }
            managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
        }
    }
    private static var _defaultManager: DataManager! = nil
    private static var _temporaryManager: DataManager! = nil
    static var defaultManager: DataManager! { // for creating cached objects
        get {
            if _defaultManager == nil {
                _defaultManager = try! DataManager(name: "WeCenterMobile")
            }
            return _defaultManager
        }
        set {
            _defaultManager = newValue
        }
    }
    static var temporaryManager: DataManager! { // for creating temporary objects
        get {
            if _temporaryManager == nil {
                _temporaryManager = try! DataManager(name: nil)
            }
            return _temporaryManager
        }
        set {
            _temporaryManager = newValue
        }
    }
    func create(entityName: String) -> DataObject {
        let entity = managedObjectModel.entitiesByName[entityName]!
        return DataObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }
    func fetch(entityName: String, ID: NSNumber) throws -> DataObject {
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "id = %@", ID)
        request.fetchLimit = 1
        let results = try managedObjectContext?.executeFetchRequest(request) ?? []
        if let result = results.first as? DataObject {
            return result
        }
        throw NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil) // Needs specification
    }
    func fetchAll(entityName: String) throws -> [DataObject] {
        let request = NSFetchRequest(entityName: entityName)
        let results = try managedObjectContext?.executeFetchRequest(request) ?? []
        return results as! [DataObject]
    }
    func autoGenerate(entityName: String, ID: NSNumber) -> DataObject {
        do {
            return try fetch(entityName, ID: ID)
        } catch _ as NSError {
            let object = create(entityName)
            object.setValue(ID, forKey: "id")
            return object
        }
    }
    func deleteAllObjectsWithEntityName(entityName: String) throws {
        try managedObjectContext?.msr_deleteAllObjectsWithEntityName(entityName)
    }
    func saveChanges() throws {
        if managedObjectContext?.hasChanges ?? false {
            try managedObjectContext?.save()
        }
    }
    var managedObjectModel: NSManagedObjectModel!
    var managedObjectContext: NSManagedObjectContext?
}
