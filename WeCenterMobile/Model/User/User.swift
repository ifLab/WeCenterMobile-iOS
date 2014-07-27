//
//  User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation

class User {
    var uid: String?

    var photoURLString:String = "7"
    
    var gender: Int = 0
    var topicNumber: Int = 0
    var iCareNumber: Int = 0
    var careMeNumber: Int = 0
    var praiseNumber: Int = 0
    var gratitudeNumber: Int = 0
//    var prestigeNumber: Int = 0
    var collectionNumber: Int = 0
    var shortIntroduction: String = " "
    var introduction: String = " "
    
    private(set) var name: String?
    private(set) var loggedIn: Bool
    let model = Model(module: "User", bundle: NSBundle.mainBundle())
    init() {
        loggedIn = false
    }
    
    func fetchInformation(
        success: ((AFHTTPRequestOperation, Msr.Data.Property) -> Void)?,
        failure: ((AFHTTPRequestOperation, NSError) -> Void)?) {
        model.GET(model.URLStrings["Information"]!,
            parameters: ["uid": uid!],
            success: {
                [weak self] operation, property in
                 println(property)
//                self!.photoURLString = property["用户头像URL"] .asString()
//                self!.name = property["用户名"] .asString()
//                self!.topicNumber = property["我的话题数"].asInt()
//                self!.iCareNumber = property["我关注的人数"].asInt()
//                self!.careMeNumber = property["关注我的人数"].asInt()
//                self!.praiseNumber = property["赞同我的次数"].asInt()
//                self!.gratitudeNumber = property["感谢我的次数"].asInt()
//                self!.collectionNumber = property["答案被收藏次数"].asInt()
                return
            }, failure: {
                operation, error in
                return
            })
    }
    
    class func loginWithCookieInStorage(
        #success: ((User) -> Void)?,
        failure: (() -> Void)?) {
            let data = NSUserDefaults.standardUserDefaults().objectForKey("Cookies") as? NSData
            if !data {
                failure?()
            } else {
                let cookies = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [NSHTTPCookie]
                println(cookies)
                let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in cookies {
                    storage.setCookie(cookie)
                }
                let user = User()
                user.loggedIn = true
                success?(user)
            }
    }
    class func loginWithName(
        name: String,
        password: String,
        success: ((User) -> Void)?,
        failure: ((NSError?, String?) -> Void)?) {
            let model = Model(module: "User", bundle: NSBundle.mainBundle())
            model.POST(model.URLStrings["Login"]!,
                parameters: [
                    "user_name": name,
                    "password": password
                ],
                success: {
                    operation, property in
                    let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as [NSHTTPCookie]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(cookies)
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(data, forKey: "Cookies")
                    defaults.synchronize()
                    if property["errno"].asInt() == -1 {
                        failure?(nil, property["err"].asString())
                    } else {
                        let user = User()
                        user.name = name
                        user.loggedIn = true
//                        user.uid = property["rsm"]["uid"].asString()
                        

                        success?(user)
                    }
                    return
                },
                failure: {
                    operation, error in
                    failure?(error, nil)
                    return
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
}
