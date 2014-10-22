//
//  DataManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    init(managedObjectContext: NSManagedObjectContext, managedObjectModel: NSManagedObjectModel) {
        self.context = managedObjectContext
        self.model = managedObjectModel
    }
    func create(entityName: String) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
        return NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)
    }
    func fetch(entityName: String, ID: NSNumber, error: NSErrorPointer) -> NSManagedObject? {
        let request = model.fetchRequestFromTemplateWithName(entityName + "_By_ID",
            substitutionVariables: [
                "ID": ID
            ])!
        let results = context.executeFetchRequest(request, error: error)
        if results != nil && results!.count != 0 {
            return results?[0] as? NSManagedObject
        } else {
            if error != nil && error.memory == nil {
                error.memory = NSError() // Needs specification
            }
            return nil
        }
    }
    func autoGenerate(entityName: String, ID: NSNumber) -> NSManagedObject {
        var object = fetch(entityName, ID: ID, error: nil)
        if object == nil {
            object = self.create(entityName)
            object!.setValue(ID, forKey: "id")
        }
        return object!
    }
    private let context: NSManagedObjectContext
    private let model: NSManagedObjectModel
}
