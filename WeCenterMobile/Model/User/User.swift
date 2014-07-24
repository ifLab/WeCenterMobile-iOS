//
//  User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation

class User {
    var uid: Int?
    private(set) var name: String?
    private(set) var loggedIn: Bool
    let model = Model(module: "User", bundle: NSBundle.mainBundle())
    init() {
        loggedIn = false
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
