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
    var photoURLString:String?
    var topicFocusCount:Int?
    var friendCount:Int?
    var fansCount:Int?
    
    var agreeCount:Int?
    var thanksCount:Int?
    var answerFavoriteCount:Int?
    
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
    func fetchUserInformation(
        #success: (() -> Void)?,
        failure: ((NSError) -> Void)?) {
        fetchUID(
            success: {
                self.model.GET(self.model.URLStrings["user_information"]!,
                    parameters: ["uid": self.uid!],
                    success: {
                        operation, property in
                        self.name = property["rsm"]["user_name"].asString()
                        self.photoURLString = property["rsm"]["avatar_file"].asString()
                        self.topicFocusCount = property["rsm"]["topic_focus_count"].asInt()
                        self.friendCount = property["rsm"]["friend_count"].asInt()
                        self.fansCount = property["rsm"]["fans_count"].asInt()
                        self.agreeCount = property["rsm"]["agree_count"].asInt()
                        self.thanksCount = property["rsm"]["thanks_count"].asInt()
                        self.topicFocusCount = property["rsm"]["topic_focus_count"].asInt()
                        success?()
                        return
                    },
                    failure: {
                        operation,error in
                        failure?(error)
                        return
                    })
                return
            }, failure: {
                error in
                failure?(error)
                return
            })
    }
    func fetchUID(
        #success: (() -> Void)?,
        failure: ((NSError) -> Void)?) {
        model.GET(model.URLStrings["Get UID"]!,
            parameters: nil,
            success: {
                operation, property in
                self.uid = property["rsm"]["uid"].asInt()
                success?()
                return
            }, failure: {
                operation, error in
                failure?(error)
                return
            })
    }
}
