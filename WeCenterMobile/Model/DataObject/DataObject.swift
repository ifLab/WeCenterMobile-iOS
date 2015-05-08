//
//  DataObject.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/8.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

protocol DataObjectProtocol {
    static func cachedObjectWithID(ID: NSNumber) -> Self
    static func temporaryObject() -> Self
    static var entityName: String { get }
}

class DataObject: NSManagedObject, DataObjectProtocol {
    
    private class func cast<T>(object: NSManagedObject, type: T.Type) -> T {
        return object as! T
    }
    
    class func cachedObjectWithID(ID: NSNumber) -> Self {
        return cast(DataManager.defaultManager!.autoGenerate(entityName, ID: ID), type: self)
    }
    
    class func temporaryObject() -> Self {
        return cast(DataManager.temporaryManager!.create(entityName), type: self)
    }
    
    class var entityName: String {
        let s = NSStringFromClass(self)
        return split(s) { $0 == "." }.last ?? s
    }
    
}
