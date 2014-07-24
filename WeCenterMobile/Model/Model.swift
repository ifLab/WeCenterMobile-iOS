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
    init(module: String, bundle: NSBundle) {
        URLStrings = Property(module: module, bundle: bundle)["URL"].asDictionary() as [String: String]
        manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: URLStrings["Base"]))
        manager.responseSerializer = AFHTTPResponseSerializer()
    }
    func GET(URLString: String,
        parameters: [String: AnyObject]!,
        success: ((AFHTTPRequestOperation, Property) -> Void)?,
        failure: ((AFHTTPRequestOperation, NSError) -> Void)?) -> Void {
            manager.GET(URLString,
                parameters: parameters,
                success: {
                    operation, data in
                    let error: NSErrorPointer = nil
                    let dictionary = NSJSONSerialization.JSONObjectWithData(data as NSData, options: nil, error: error) as NSDictionary
                    if !error {
                        success?(operation, Property(value: dictionary))
                    } else {
                        failure?(operation, error.memory!)
                    }
                    return
                },
                failure: {
                    operation, error in
                    failure?(operation, error)
                    return
                })
    }
    func POST(URLString: String,
        parameters: [String: AnyObject]!,
        success: ((AFHTTPRequestOperation, Property) -> Void)?,
        failure: ((AFHTTPRequestOperation, NSError) -> Void)?) -> Void {
            manager.POST(URLString,
                parameters: parameters,
                constructingBodyWithBlock: nil,
                success: {
                    operation, data in
                    let error: NSErrorPointer = nil
                    let dictionary = NSJSONSerialization.JSONObjectWithData(data as NSData, options: nil, error: error) as NSDictionary
                    if !error {
                        success?(operation, Property(value: dictionary))
                    } else {
                        failure?(operation, error.memory!)
                    }
                    return
                },
                failure: {
                    operation, error in
                    failure?(operation, error)
                    return
                })
    }
}
