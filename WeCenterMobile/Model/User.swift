//
//  User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/1.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

let UserModel = Model(module: "User", bundle: NSBundle.mainBundle())
let UserStrings = Msr.Data.LocalizedStrings(module: "User", bundle: NSBundle.mainBundle())

class User: NSManagedObject {
    
    enum Gender: Int {
        case Male = 1
        case Female = 2
        case Secret = 3
    }
    
    @NSManaged var gender: NSNumber?
    @NSManaged var birthday: NSNumber?
    @NSManaged var jobID: NSNumber?
    @NSManaged var signature: String?
    @NSManaged var agreementCount: NSNumber?
    @NSManaged var answerFavoriteCount: NSNumber?
    @NSManaged var answerCount: NSNumber?
    @NSManaged var avatarURL: String?
    @NSManaged var followerCount: NSNumber?
    @NSManaged var followingCount: NSNumber?
    @NSManaged var friendCount: NSNumber?
    @NSManaged var id: NSNumber
    @NSManaged var markCount: NSNumber?
    @NSManaged var name: String?
    @NSManaged var questionCount: NSNumber?
    @NSManaged var thankCount: NSNumber?
    @NSManaged var topicFocusCount: NSNumber?
    var followed: Bool? = nil
    
    class func clearCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies as [NSHTTPCookie] {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey("Cookies")
        NSUserDefaults.standardUserDefaults().synchronize()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    
    class func fetchUserByID(ID: NSNumber, strategy: Model.Strategy, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchUserUsingCacheByID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchUserUsingNetworkByID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchUserUsingCacheByID(ID, success: success, failure: {
                error in
                self.fetchUserUsingNetworkByID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchUserUsingNetworkByID(ID, success: success, failure: {
                error in
                self.fetchUserUsingCacheByID(ID, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    private class func fetchUserUsingCacheByID(ID: NSNumber, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("User_By_ID", ID: ID, success: success, failure: failure)
    }
    
    private class func fetchUserUsingNetworkByID(ID: NSNumber, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        UserModel.GET(UserModel.URLStrings["Information"]!,
            parameters: [
                "uid": ID
            ],
            success: {
                property in
                self.fetchUserUsingCacheByID(ID,
                    success: {
                        user in
                        user.updateMainInformationWithProperty(property)
                        user.id = ID
                        appDelegate.saveContext()
                        success?(user)
                    }, failure: {
                        error in
                        let user = Model.createManagedObjectOfClass(User.self, entityName: "User") as User
                        user.updateMainInformationWithProperty(property)
                        user.id = ID
                        appDelegate.saveContext()
                        success?(user)
                })
            }, failure: failure)
    }
    
    class func loginWithCookieAndCacheInStorage(
        #success: ((User) -> Void)?,
        failure: ((NSError) -> Void)?) {
            let data = NSUserDefaults.standardUserDefaults().objectForKey("Cookies") as? NSData
            if data == nil {
                failure?(NSError()) // Needs specification
            } else {
                let cookies = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [NSHTTPCookie]
                let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in cookies {
                    storage.setCookie(cookie)
                }
                UserModel.GET(UserModel.URLStrings["Get UID"]!,
                    parameters: nil,
                    success: {
                        property in
                        self.fetchUserByID(
                            property["uid"].asInt(),
                            strategy: .CacheFirst,
                            success: success, failure: failure)
                    }, failure: failure)
            }
    }
    
    class func loginWithName(
        name: String,
        password: String,
        success: ((User) -> Void)?,
        failure: ((NSError) -> Void)?) {
            clearCookies()
            UserModel.POST(UserModel.URLStrings["Login"]!,
                parameters: [
                    "user_name": name.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding),
                    "password": password.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                ],
                success: {
                    property in
                    let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as [NSHTTPCookie]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(cookies)
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(data, forKey: "Cookies")
                    defaults.synchronize()
                    self.loginWithCookieAndCacheInStorage(success: success, failure: failure)
                },
                failure: failure)
    }
    
    func fetchProfileUsingNetwork(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        UserModel.GET(UserModel.URLStrings["profile"]!,
            parameters: [
                "uid": id
            ],
            success: {
                property in
                self.updateAdditionalInformationWithProperty(property[0])
                success?()
            },
            failure: failure)
    }
    
    func toggleFollow(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        UserModel.GET(UserModel.URLStrings["Follow User"]!,
            parameters: [
                "uid": id
            ],
            success: {
                property in
                self.followed = (property["type"].asString() == "add")
                success?()
            },
            failure: failure)
    }
    
    class func avatarURLWithURI(URI: String) -> String {
        return UserModel.URLStrings["Base"]! + UserModel.URLStrings["Avatar Base"]! + URI
    }
    
    private func updateMainInformationWithProperty(property: Msr.Data.Property) {
        let data = property
        name = data["user_name"].asString()
        avatarURL = User.avatarURLWithURI(data["avatar_file"].asString())
        followerCount = data["fans_count"].asInt()
        friendCount = data["friend_count"].asInt()
        questionCount = data["question_count"].asInt()
        answerCount = data["answer_count"].asInt()
        topicFocusCount = data["topic_focus_count"].asInt()
        agreementCount = data["agree_count"].asInt()
        thankCount = data["thanks_count"].asInt()
        answerFavoriteCount = data["answer_favorite_count"].asInt()
        followed = (data["has_focus"].asInt() == 1)
        appDelegate.saveContext()
    }
    
    private func updateAdditionalInformationWithProperty(property: Msr.Data.Property) {
        let data = property
        name = data["user_name"].asString()
        gender = data["sex"].isNull() ? Gender.Secret.toRaw() : data["sex"].asInt()
        birthday = data["birthday"].isNull() ? 0 : data["birthday"].asInt()
        jobID = data["job_id"].asInt()
        signature = data["signature"].asString()
        appDelegate.saveContext()
    }
    
}
