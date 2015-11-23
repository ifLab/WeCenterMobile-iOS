//
//  DataObject.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/8.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

enum SearchType: String {
    case All = "all"
    case Article = "articles"
    case Question = "questions"
    case Topic = "topics"
    case User = "users"
}

class DataObject: NSManagedObject {
    
    @NSManaged var id: NSNumber!
    
    private class func cast<T>(object: NSManagedObject, type: T.Type) -> T {
        return object as! T
    }
    
    class func cachedObjectWithID(ID: NSNumber) -> Self {
        return cast(DataManager.defaultManager!.autoGenerate(entityName, ID: ID), type: self)
    }
    
    class func allCachedObjects() -> [DataObject] /* [Self] in not supported. */ {
        return try! DataManager.defaultManager!.fetchAll(entityName)
    }
    
    class func deleteAllCachedObjects() {
        try! DataManager.defaultManager!.deleteAllObjectsWithEntityName(entityName)
    }
    
    class func temporaryObject() -> Self {
        return cast(DataManager.temporaryManager!.create(entityName), type: self)
    }
    
    class var entityName: String {
        let s = NSStringFromClass(self)
        return s.characters.split { $0 == "." }.map { String($0) }.last ?? s
    }
    
}
