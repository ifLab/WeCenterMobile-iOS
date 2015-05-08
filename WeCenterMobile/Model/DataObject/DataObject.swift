//
//  DataObject.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/8.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class DataObject: NSManagedObject {
    
    @NSManaged var id: NSNumber!
    
    private class func cast<T>(object: NSManagedObject, type: T.Type) -> T {
        return object as! T
    }
    
    class func cachedObjectWithID(ID: NSNumber) -> Self {
        return cast(DataManager.defaultManager!.autoGenerate(entityName, ID: ID), type: self)
    }
    
    class func allCachedObjects() -> [DataObject] /* [Self] in not supported. */ {
        return DataManager.defaultManager!.fetchAll(entityName, error: nil)
    }
    
    class func deleteAllCachedObjects() {
        DataManager.defaultManager!.deleteAllObjectsWithEntityName(entityName)
    }
    
    class func temporaryObject() -> Self {
        return cast(DataManager.temporaryManager!.create(entityName), type: self)
    }
    
    class var entityName: String {
        let s = NSStringFromClass(self)
        return split(s) { $0 == "." }.last ?? s
    }
    
}
