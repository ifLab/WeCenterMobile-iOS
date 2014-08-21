//
//  Model.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Model {
    let URLStrings: [String: String]
    let manager: AFHTTPRequestOperationManager
    let noError = 1
    let internalErrorCode = 23333
    enum Strategy {
        case NetworkOnly
        case CacheOnly
        case CacheFirst
        case NetworkFirst
    }
    init(module: String, bundle: NSBundle) {
        let path = bundle.pathForResource(module, ofType: "plist")!
        URLStrings = NSDictionary(contentsOfFile: path)["URL"] as [String: String]
        manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: URLStrings["Base"]!))
        manager.responseSerializer = AFHTTPResponseSerializer()
    }
    func GET(URLString: String,
        parameters: NSDictionary?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> Void {
            let application = UIApplication.sharedApplication()
            application.networkActivityIndicatorVisible = true
            manager.GET(URLString,
                parameters: parameters,
                success: {
                    operation, data in
                    application.networkActivityIndicatorVisible = false
                    self.handleSuccess(data: data as NSData, success: success, failure: failure)
                },
                failure: {
                    operation, error in
                    application.networkActivityIndicatorVisible = false
                    failure?(error)
                })
    }
    func POST(URLString: String,
        parameters: NSDictionary?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> Void {
            let application = UIApplication.sharedApplication()
            application.networkActivityIndicatorVisible = true
            manager.POST(URLString,
                parameters: parameters,
                constructingBodyWithBlock: nil,
                success: {
                    operation, data in
                    application.networkActivityIndicatorVisible = false
                    self.handleSuccess(data: data as NSData, success: success, failure: failure)
                },
                failure: {
                    operation, error in
                    application.networkActivityIndicatorVisible = false
                    failure?(error)
                })
    }
    private func handleSuccess(#data: NSData, success: ((AnyObject) -> Void)?, failure: ((NSError) -> Void)?) {
        let error: NSErrorPointer = nil
        let object: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error)
        if object == nil {
            failure?(NSError()) // Needs specification
            return
        }
        let data = object as NSDictionary
        if error == nil {
            if data["errno"] as? NSNumber == noError {
                success?(data["rsm"]!)
            } else {
                failure?(NSError(
                    domain: self.URLStrings["Base"]!,
                    code: self.internalErrorCode,
                    userInfo: ["Hint": data["err"] as String]))
            }
        } else {
            failure?(error.memory!)
        }
    }
    class func createManagedObjecWithEntityName(entityName: String) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: appDelegate.managedObjectContext)
        return NSManagedObject(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
    }
    class func fetchManagedObjectByTemplateName<T: NSManagedObject>(templateName: String, ID: NSNumber, success: ((T) -> Void)?, failure: ((NSError) -> Void)?) {
        let request = appDelegate.managedObjectModel.fetchRequestFromTemplateWithName(templateName,
            substitutionVariables: [
                "ID": ID
            ])
        var error: NSError? = nil
        let results = appDelegate.managedObjectContext.executeFetchRequest(request, error: &error)
        if error == nil && results != nil && results!.count != 0 {
            success?(results![0] as T)
        } else {
            failure?(error != nil ? error! : NSError()) // Needs specification
        }
    }
    class func autoGenerateManagedObjectByEntityName(entityName: String, ID: NSNumber) -> NSManagedObject {
        var object: NSManagedObject! = nil
        fetchManagedObjectByTemplateName(entityName + "_By_ID",
            ID: ID,
            success: {
                (_object: NSManagedObject) -> Void in
                object = _object
            }, failure: {
                error in
                object = self.createManagedObjecWithEntityName(entityName)
                object.setValue(ID, forKey: "id")
            })
        return object
    }
    class func fetchRelationshipsByTemplateName<T: NSManagedObject>(templateName: String, ID: NSNumber, page: Int, count: Int, sortBy: (String, Bool)? = nil, success: (([T]) -> Void)?, failure: ((NSError) -> Void)?) {
        let request = appDelegate.managedObjectModel.fetchRequestFromTemplateWithName(templateName,
            substitutionVariables: [
                "ID": ID
            ])
        request.fetchLimit = count
        request.fetchOffset = (page - 1) * count
        if sortBy != nil {
            request.sortDescriptors = [NSSortDescriptor(key: sortBy!.0, ascending: sortBy!.1)]
        }
        var error: NSError? = nil
        let results = appDelegate.managedObjectContext.executeFetchRequest(request, error: &error)
        if error == nil && results != nil && results!.count != 0 {
            success?(results as [T])
        } else {
            failure?(error != nil ? error! : NSError()) // Needs specification
        }
    }
    class func relationshipExists(templateName: String, a: (String, NSNumber), b: (String, NSNumber)) -> Bool {
        let request = appDelegate.managedObjectModel.fetchRequestFromTemplateWithName(templateName,
            substitutionVariables: [
                a.0: a.1,
                b.0: b.1
            ])
        var error: NSError? = nil
        let results = appDelegate.managedObjectContext.executeFetchRequest(request, error: &error)
        return error == nil && results != nil && results!.count != 0
    }
}
