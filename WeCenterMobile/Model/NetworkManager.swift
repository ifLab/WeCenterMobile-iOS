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
                    self.handleSuccess(data: data as NSData, success: success, failure: failure)
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
                    self.handleSuccess(data: data as NSData, success: success, failure: failure)
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
    private func handleSuccess(#data: NSData, success: ((AnyObject) -> Void)?, failure: ((NSError) -> Void)?) {
        var error: NSError? = nil
        let object: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
        if object == nil {
            failure?(NSError()) // Needs specification
            return
        }
        let data = object as NSDictionary
        if error == nil {
            if data["errno"] as NSNumber == successCode {
                success?(data["rsm"]!)
                appDelegate.saveContext() // It's not a good idea to place this here, but it can reduce duplicated codes.
            } else {
                failure?(NSError(
                    domain: website,
                    code: self.internalErrorCode.integerValue,
                    userInfo: ["Hint": data["err"] as String]))
            }
        } else {
            failure?(error!)
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
