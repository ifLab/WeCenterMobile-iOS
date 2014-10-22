//
//  Model.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

struct Model {
    static let configuration: NSDictionary = {
        return NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Configuration", ofType: "plist")!)
    }()
    static var website: String {
        return configuration["Website"] as String
    }
    static var paths: [String: String] {
        return configuration["Path"] as [String: String]
    }
    static let manager: AFHTTPRequestOperationManager = {
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: website))
        manager.responseSerializer = AFHTTPResponseSerializer()
        return manager
    }()
    static let noError = 1
    static let internalErrorCode = 23333
    enum Strategy {
        case NetworkOnly
        case CacheOnly
        case CacheFirst
        case NetworkFirst
    }
    static func GET(key: String,
        parameters: NSDictionary?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> Void {
            let application = UIApplication.sharedApplication()
            application.networkActivityIndicatorVisible = true
            manager.GET(paths[key]!,
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
    static func POST(key: String,
        parameters: NSDictionary?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> Void {
            let application = UIApplication.sharedApplication()
            application.networkActivityIndicatorVisible = true
            manager.POST(paths[key]!,
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
    static private func handleSuccess(#data: NSData, success: ((AnyObject) -> Void)?, failure: ((NSError) -> Void)?) {
        var error: NSError? = nil
        let object: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
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
                    domain: website,
                    code: self.internalErrorCode,
                    userInfo: ["Hint": data["err"] as String]))
            }
        } else {
            failure?(error!)
        }
    }
    static func createManagedObjecWithEntityName(entityName: String) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: appDelegate.managedObjectContext!)!
        return NSManagedObject(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
    }
    static func fetchManagedObjectByTemplateName<T: NSManagedObject>(templateName: String, ID: NSNumber, success: ((T) -> Void)?, failure: ((NSError) -> Void)?) {
        let request = appDelegate.managedObjectModel.fetchRequestFromTemplateWithName(templateName,
            substitutionVariables: [
                "ID": ID
            ])!
        var error: NSError? = nil
        let results = appDelegate.managedObjectContext!.executeFetchRequest(request, error: &error)
        if error == nil && results != nil && results!.count != 0 {
            success?(results![0] as T)
        } else {
            failure?(error != nil ? error! : NSError()) // Needs specification
        }
    }
    static func autoGenerateManagedObjectByEntityName(entityName: String, ID: NSNumber) -> NSManagedObject {
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
}
