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
                var user: User! = nil
                self.fetchUserUsingCacheByID(ID,
                    success: {
                        _user in
                        user = _user
                        return
                    }, failure: {
                        error in
                        user = Model.createManagedObjecWithEntityName("User") as User
                        return
                    })
                user.id = ID
                user.name = property["user_name"].asString()
                user.avatarURL = User.avatarURLWithURI(property["avatar_file"].asString())
                user.followerCount = property["fans_count"].asInt()
                user.friendCount = property["friend_count"].asInt()
                user.questionCount = property["question_count"].asInt()
                user.answerCount = property["answer_count"].asInt()
                user.topicFocusCount = property["topic_focus_count"].asInt()
                user.agreementCount = property["agree_count"].asInt()
                user.thankCount = property["thanks_count"].asInt()
                user.answerFavoriteCount = property["answer_favorite_count"].asInt()
                user.followed = (property["has_focus"].asInt() == 1)
                appDelegate.saveContext()
                success?(user)
            }, failure: failure)
    }
    
    class func fetchFollowingListByUserID(ID: NSNumber, strategy: Model.Strategy, page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchFollowingListUsingCacheByUserID(ID, page: page, count: count, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchFollowingListUsingNetworkByUserID(ID, page: page, count: count, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchFollowingListUsingCacheByUserID(ID, page: page, count: count, success: success, failure: {
                error in
                self.fetchFollowingListUsingNetworkByUserID(ID, page: page, count: count, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchFollowingListUsingNetworkByUserID(ID, page: page, count: count, success: success, failure: {
                error in
                self.fetchFollowingListUsingCacheByUserID(ID, page: page, count: count, success: success, failure: failure)
            })
            break
        }
    }
    
    private class func fetchFollowingListUsingNetworkByUserID(ID: NSNumber, page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        UserModel.GET(UserModel.URLStrings["GET Following List"]!,
            parameters: [
                "uid": ID,
                "page": page,
                "per_page": count
            ],
            success: {
                property in
                if property["total_rows"].asInt() > 0 {
                    var users = [User]()
                    let userProperties = property["rows"]
                    let a = ID
                    for userDictionary in userProperties.asArray() as [NSDictionary] {
                        let value = Msr.Data.Property(value: userDictionary)
                        var user: User! = nil
                        let b = value["uid"].asInt()
                        User_User.updateRelationship(a: a, b: b)
                        User.fetchUserByID(b,
                            strategy: .CacheOnly,
                            success: {
                                _user in
                                user = _user
                                return
                            },
                            failure: {
                                error in
                                user = Model.createManagedObjecWithEntityName("User") as User
                                user.id = b
                                return
                            })
                        user.name = value["user_name"].asString()
                        user.avatarURL = User.avatarURLWithURI(value["avatar_file"].asString())
                        user.signature = value["signature"].asString()
                        users.append(user)
                    }
                    appDelegate.saveContext()
                    success?(users)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: {
                error in
                println(error.userInfo)
                return
            })
    }
    
    private class func fetchFollowingListUsingCacheByUserID(ID: NSNumber, page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("User_User_By_UserAID",
            ID: ID,
            page: page,
            count: count,
            sortBy: nil,
            success: {
                user_users in
                var users = [User]()
                for user_user in user_users as [User_User] {
                    User.fetchUserByID(user_user.b,
                        strategy: .CacheOnly,
                        success: {
                            user in
                            users.append(user)
                        },
                        failure: nil)
                }
                success?(users)
            },
            failure: failure)
    }
    
    class func fetchFollowerListByUserID(ID: NSNumber, strategy: Model.Strategy, page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchFollowerListUsingCacheByUserID(ID, page: page, count: count, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchFollowerListUsingNetworkByUserID(ID, page: page, count: count, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchFollowerListUsingCacheByUserID(ID, page: page, count: count, success: success, failure: {
                error in
                self.fetchFollowerListUsingNetworkByUserID(ID, page: page, count: count, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchFollowerListUsingNetworkByUserID(ID, page: page, count: count, success: success, failure: {
                error in
                self.fetchFollowerListUsingCacheByUserID(ID, page: page, count: count, success: success, failure: failure)
            })
            break
        }
    }
    
    private class func fetchFollowerListUsingNetworkByUserID(ID: NSNumber, page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        UserModel.GET(UserModel.URLStrings["GET Follower List"]!,
            parameters: [
                "uid": ID,
                "page": page,
                "per_page": count
            ],
            success: {
                property in
                if property["total_rows"].asInt() > 0 {
                    var users = [User]()
                    let userProperties = property["rows"]
                    let b = ID
                    for userDictionary in userProperties.asArray() as [NSDictionary] {
                        let value = Msr.Data.Property(value: userDictionary)
                        var user: User! = nil
                        let a = value["uid"].asInt()
                        User_User.updateRelationship(a: a, b: b)
                        User.fetchUserByID(a,
                            strategy: .CacheOnly,
                            success: {
                                _user in
                                user = _user
                                return
                            },
                            failure: {
                                error in
                                user = Model.createManagedObjecWithEntityName("User") as User
                                user.id = a
                                return
                            })
                        user.name = value["user_name"].asString()
                        user.avatarURL = User.avatarURLWithURI(value["avatar_file"].asString())
                        user.signature = value["signature"].asString()
                        users.append(user)
                    }
                    appDelegate.saveContext()
                    success?(users)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: {
                error in
                println(error.userInfo)
                return
            })
    }
    
    private class func fetchFollowerListUsingCacheByUserID(ID: NSNumber, page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("User_User_By_UserBID",
            ID: ID,
            page: page,
            count: count,
            sortBy: nil,
            success: {
                user_users in
                var users = [User]()
                for user_user in user_users as [User_User] {
                    User.fetchUserByID(user_user.a,
                        strategy: .CacheOnly,
                        success: {
                            user in
                            users.append(user)
                        },
                        failure: nil)
                }
                success?(users)
            },
            failure: failure)
    }
    
    class func loginWithCookieAndCacheInStorage(#success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
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
    
    class func loginWithName(name: String, password: String, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
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
    
    // Needs to be modified
    func fetchProfileUsingNetwork(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        UserModel.GET(UserModel.URLStrings["profile"]!,
            parameters: [
                "uid": id
            ],
            success: {
                property in
                let data = property[0]
                self.name = data["user_name"].asString()
                self.gender = data["sex"].isNull() ? Gender.Secret.toRaw() : data["sex"].asInt()
                self.birthday = data["birthday"].isNull() ? 0 : data["birthday"].asInt()
                self.jobID = data["job_id"].asInt()
                self.signature = data["signature"].asString()
                appDelegate.saveContext()
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
    
}
