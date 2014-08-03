//
//  Model.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation

class Model {
    typealias Property = Msr.Data.Property
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
        URLStrings = Property(module: module, bundle: bundle)["URL"].asDictionary() as [String: String]
        manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: URLStrings["Base"]))
        manager.responseSerializer = AFHTTPResponseSerializer()
    }
    func GET(URLString: String,
        parameters: [String: AnyObject]!,
        success: ((Property) -> Void)?,
        failure: ((NSError) -> Void)?) -> Void {
            manager.GET(URLString,
                parameters: parameters,
                success: {
                    operation, data in
                    self.handleSuccess(data: data as NSData, success: success, failure: failure)
                },
                failure: {
                    operation, error in
                    failure?(error)
                    return
                })
    }
    func POST(URLString: String,
        parameters: [String: AnyObject]!,
        success: ((Property) -> Void)?,
        failure: ((NSError) -> Void)?) -> Void {
            manager.POST(URLString,
                parameters: parameters,
                constructingBodyWithBlock: nil,
                success: {
                    operation, data in
                    self.handleSuccess(data: data as NSData, success: success, failure: failure)
                },
                failure: {
                    operation, error in
                    failure?(error)
                    return
                })
    }
    private func handleSuccess(#data: NSData, success: ((Property) -> Void)?, failure: ((NSError) -> Void)?) {
        let error: NSErrorPointer = nil
        let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error) as NSDictionary
        if !error {
            let value = Property(value: dictionary)
            if value["errno"].asInt() == self.noError {
                success?(Property(value: value["rsm"].value))
            } else {
                failure?(NSError(
                    domain: self.URLStrings["Base"],
                    code: self.internalErrorCode,
                    userInfo: ["Hint": value["err"].asString()]))
            }
        } else {
            failure?(error.memory!)
        }
    }
}
