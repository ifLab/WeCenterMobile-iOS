//
//  NetworkManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFNetworking
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
        parameters: [String: AnyObject],
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
            return request(key,
                GETParameters: parameters,
                POSTParameters: [:],
                constructingBodyWithBlock: nil,
                success: success,
                failure: failure)
    }
    func POST(key: String,
        parameters: [String: AnyObject],
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
            return request(key,
                GETParameters: [:],
                POSTParameters: parameters,
                constructingBodyWithBlock: nil,
                success: success,
                failure: failure)
    }
    func request(key: String,
        var GETParameters: [String: AnyObject],
        POSTParameters: [String: AnyObject],
        constructingBodyWithBlock block: ((AFMultipartFormData?) -> Void)?,
        success: ((AnyObject) -> Void)?,
        failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
            do {
                GETParameters["mobile_sign"] = getMobileSignWithPath(paths[key]!)
                let URLString = try manager.requestSerializer.requestWithMethod("GET", URLString: paths[key]!, parameters: GETParameters, error: ()).URL!.absoluteString
                return manager.POST(URLString,
                    parameters: POSTParameters,
                    constructingBodyWithBlock: block,
                    success: {
                        [weak self] operation, data in
                        self?.handleSuccess(operation: operation, data: data as! NSData, success: success, failure: failure)
                    },
                    failure: {
                        operation, error in
                        failure?(error)
                    })
            } catch let error as NSError {
                failure?(error)
                return nil
            }
    }
    class func clearCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsCookiesKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsUserIDKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    private func handleSuccess(operation operation: AFHTTPRequestOperation, data: NSData, success: ((AnyObject) -> Void)?, failure: ((NSError) -> Void)?) {
        let object: AnyObject
        do {
            object = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        } catch let error as NSError {
            var userInfo = [
                NSLocalizedDescriptionKey: "Failed to parse JSON.",
                NSLocalizedFailureReasonErrorKey: "The data returned from the server does not meet the JSON syntax.",
                NSURLErrorKey: operation.response.URL!
            ]
            userInfo[NSUnderlyingErrorKey] = error
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
            _ = try? DataManager.defaultManager!.saveChanges() // It's not a good idea to be placed here, but this could reduce duplicate codes.
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
    var appSecret: String? {
        return configuration["App Secret"] as? String
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
