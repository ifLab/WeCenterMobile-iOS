//
//  NetworkManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation

class NetworkManager: NSObject {
    required init?(configuration: NSDictionary) {
        self.configuration = configuration
        super.init()
        if configuration["Website"] as? String == nil
        || configuration["Path"] as? [String: String] == nil
        || configuration["Success Code"] as? NSNumber == nil
        || configuration["Internal Error Code"] as? NSNumber == nil {
            return nil
        }
    }
    static var defaultManager = NetworkManager(configuration: NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Configuration", ofType: "plist")!)!)
    func GET(key: String,
        parameters: NSDictionary?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
            return request(key,
                GETParameters: parameters,
                POSTParameters: nil,
                constructingBodyWithBlock: nil,
                success: success,
                failure: failure)
    }
    func POST(key: String,
        parameters: NSDictionary?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
            return request(key,
                GETParameters: nil,
                POSTParameters: parameters,
                constructingBodyWithBlock: nil,
                success: success,
                failure: failure)
    }
    func request(key: String,
        GETParameters: NSDictionary?,
        POSTParameters: NSDictionary?,
        constructingBodyWithBlock block: ((AFMultipartFormData?) -> Void)?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
            var error: NSError? = nil
            let URLString = manager.requestSerializer.requestWithMethod("GET", URLString: paths[key]!, parameters: GETParameters, error: &error).URL?.absoluteString
            if error != nil || URLString == nil {
                failure?(error ?? NSError()) // Needs specification
                return nil
            }
            return manager.POST(URLString!,
                parameters: POSTParameters,
                constructingBodyWithBlock: block,
                success: {
                    operation, data in
                    self.handleSuccess(operation: operation, data: data as! NSData, success: success, failure: failure)
                },
                failure: {
                    operation, error in
                    failure?(error)
                })
    }
    class func clearCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies as! [NSHTTPCookie] {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsCookiesKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsUserIDKey)
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
            let error = NSError(
                domain: website,
                code: self.internalErrorCode.integerValue,
                userInfo: userInfo)
            NSLog("\(operation.response.URL!)\n\(error)\n\(NSString(data: data, encoding: NSUTF8StringEncoding)))")
            failure?(error)
            return
        }
        let data = object as! NSDictionary
        if data["errno"] as! NSNumber == successCode {
            let info: AnyObject = data["rsm"]!
//            NSLog("\(operation.response.URL!)\n\(info)")
            success?(info)
            DataManager.defaultManager!.saveChanges(nil) // It's not a good idea to be placed here, but this could reduce duplicate codes.
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
            failure?(error)
        }
    }
    private let configuration: NSDictionary
    var website: String {
        return configuration["Website"] as! String
    }
    var paths: [String: String] {
        return configuration["Path"] as! [String: String]
    }
    private lazy var manager: AFHTTPRequestOperationManager = {
        [weak self] in
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: self?.website ?? ""))
        manager.responseSerializer = AFHTTPResponseSerializer()
        return manager
    }()
    var successCode: NSNumber {
        return configuration["Success Code"] as! NSNumber
    }
    var internalErrorCode: NSNumber {
        return configuration["Internal Error Code"] as! NSNumber
    }
}
