//
//  NetworkManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation

class NetworkManager {
    init(configuration: NSDictionary) {
        self.configuration = configuration
    }
    func GET(key: String,
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
                    self.handleSuccess(operation: operation, data: data as NSData, success: success, failure: failure)
                },
                failure: {
                    operation, error in
                    application.networkActivityIndicatorVisible = false
                    failure?(error)
                })
    }
    func POST(key: String,
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
                    self.handleSuccess(operation: operation, data: data as NSData, success: success, failure: failure)
                },
                failure: {
                    operation, error in
                    application.networkActivityIndicatorVisible = false
                    failure?(error)
                })
    }
    class func clearCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies as [NSHTTPCookie] {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey("Cookies")
        NSUserDefaults.standardUserDefaults().synchronize()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    private func handleSuccess(#operation: AFHTTPRequestOperation, data: NSData, success: ((AnyObject) -> Void)?, failure: ((NSError) -> Void)?) {
        var error: NSError? = nil
        let object: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
        if error != nil || object == nil || !(object is NSDictionary) {
            var userInfo = [
                NSLocalizedDescriptionKey: "Failed to parse JSON.",
                NSLocalizedFailureReasonErrorKey: "The data returned from the server does not meet the JSON syntax.",
                NSURLErrorKey: operation.response.URL!
            ]
            if operation.error != nil {
                userInfo[NSUnderlyingErrorKey] = operation.error
            }
            failure?(NSError(
                domain: website,
                code: self.internalErrorCode.integerValue,
                userInfo: userInfo)) // Needs specification
            return
        }
        let data = object as NSDictionary
        if data["errno"] as NSNumber == successCode {
            let info: AnyObject = data["rsm"]!
            NSLog("\(operation.response.URL!)\n\(info)")
            success?(info)
            appDelegate.saveContext() // It's not a good idea to be placed here, but this could reduce duplicated codes.
        } else {
            var userInfo = [
                NSLocalizedDescriptionKey: data["err"]!,
                NSURLErrorKey: operation.response.URL!
            ]
            if operation.error != nil {
                userInfo[NSUnderlyingErrorKey] = operation.error
            }
            let error = NSError(
                domain: website,
                code: self.internalErrorCode.integerValue,
                userInfo: userInfo)
            NSLog("\(error)")
            failure?(error) // Needs specification
        }
    }
    let configuration: NSDictionary
    var website: String {
        return configuration["Website"] as String
    }
    var paths: [String: String] {
        return configuration["Path"] as [String: String]
    }
    lazy var manager: AFHTTPRequestOperationManager = {
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: self.website))
        manager.responseSerializer = AFHTTPResponseSerializer()
        return manager
    }()
    var successCode: NSNumber {
        return configuration["Success Code"] as NSNumber
    }
    var internalErrorCode: NSNumber {
        return configuration["Internal Error Code"] as NSNumber
    }
}
