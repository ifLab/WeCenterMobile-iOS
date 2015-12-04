//
//  User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import AFNetworking
import CoreData
import UIKit

let UserDefaultsCookiesKey = "WeCenterMobile_DefaultCookies"
let UserDefaultsUserIDKey = "WeCenterMobile_DefaultUserID"
let CurrentUserDidChangeNotificationName = "CurrentUserDidChangeNotification"
let CurrentUserPropertyDidChangeNotificationName = "CurrentUserPropertyDidChangeNotification"
let KeyUserInfoKey = "KeyPathUserInfo"

class User: DataObject {
    
    static var currentUser: User? = nil {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(CurrentUserDidChangeNotificationName, object: nil)
        }
    }

    var isCurrentUser: Bool {
        return id == User.currentUser?.id
    }
    
    @NSManaged var agreementCount: NSNumber?
    @NSManaged var answerCount: NSNumber?
    @NSManaged var answerFavoriteCount: NSNumber?
    @NSManaged var articleCount: NSNumber?
    @NSManaged var avatarData: NSData?
    @NSManaged var avatarURI: String?
    @NSManaged var birthday: NSDate?
    @NSManaged var followerCount: NSNumber?
    @NSManaged var followingCount: NSNumber?
    @NSManaged var genderValue: NSNumber?
    @NSManaged var jobID: NSNumber?
    @NSManaged var markCount: NSNumber?
    @NSManaged var name: String?
    @NSManaged var questionCount: NSNumber?
    @NSManaged var signature: String?
    @NSManaged var thankCount: NSNumber?
    @NSManaged var topicFocusCount: NSNumber?
    @NSManaged var actions: Set<Action>
    @NSManaged var answers: Set<Answer>
    @NSManaged var articles: Set<Article>
    @NSManaged var answerComments: Set<AnswerComment>
    @NSManaged var answerCommentsMentioned: Set<AnswerComment>
    @NSManaged var featuredQuestionAnswers: Set<FeaturedQuestionAnswer>
    @NSManaged var followers: Set<User>
    @NSManaged var followings: Set<User>
    @NSManaged var questions: Set<Question>
    @NSManaged var topics: Set<Topic>
    @NSManaged var articleComments: Set<ArticleComment>
    @NSManaged var articleCommentsMentioned: Set<ArticleComment>
    
    enum Gender: Int {
        case Male = 1
        case Female = 2
        case Secret = 3
    }
    
    var gender: Gender? {
        get {
            return (genderValue == nil) ? nil : Gender(rawValue: genderValue!.integerValue)
        }
        set {
            genderValue = newValue?.rawValue
        }
    }
    
    var avatar: UIImage? {
        get {
            if avatarData != nil {
                return UIImage(data: avatarData!)
            } else {
                return nil
            }
        }
        set {
            avatarData = newValue == nil ? nil : UIImagePNGRepresentation(newValue!)
        }
    }
    
    var following: Bool? = nil
    
    var avatarURL: String? {
        get {
            return (avatarURI == nil) ? nil : NetworkManager.defaultManager!.website + NetworkManager.defaultManager!.paths["User Avatar"]! + avatarURI!
        }
        set {
            if let replacedString = newValue?.stringByReplacingOccurrencesOfString(NetworkManager.defaultManager!.website + NetworkManager.defaultManager!.paths["User Avatar"]!, withString: "") {
                if replacedString != newValue {
                    avatarURI = replacedString
                } else {
                    avatarURI = nil
                }
            } else {
                avatarURI = nil
            }
        }
    }
    
    class func fetch(ID ID: NSNumber, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Extra Information",
            parameters: [
                "uid": ID
            ],
            success: {
                data in
                let data = data as! NSDictionary
                let user = User.cachedObjectWithID(ID)
                user.id = ID
                user.name = data["user_name"] as? String
                user.avatarURL = data["avatar_file"] as? String
                user.followerCount = Int(msr_object: data["fans_count"])
                user.followingCount = Int(msr_object: data["friend_count"])
                user.questionCount = Int(msr_object: data["question_count"])
                user.answerCount = Int(msr_object: data["answer_count"])
                user.articleCount = Int(msr_object: data["article_count"])
                user.topicFocusCount = Int(msr_object: data["topic_focus_count"])
                user.agreementCount = Int(msr_object: data["agree_count"])
                user.thankCount = Int(msr_object: data["thanks_count"])
                user.answerFavoriteCount = Int(msr_object: data["answer_favorite_count"])
                user.following = (data["has_focus"] as! NSNumber == 1)
                _ = try? DataManager.defaultManager.saveChanges()
                success?(user)
            },
            failure: failure)
    }
    
    func fetchFollowings(page page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Following List",
            parameters: [
                "uid": id,
                "type": "follows",
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    if Int(msr_object: data["total_rows"]!!) > 0 && data["rows"] is [NSDictionary] {
                        var users = [User]()
                        for value in data["rows"] as! [NSDictionary] {
                            let userID = Int(msr_object: value["uid"])
                            let user = User.cachedObjectWithID(userID!)
                            user.name = value["user_name"] as? String
                            user.avatarURL = value["avatar_file"] as? String
                            user.signature = value["signature"] as? String
                            self_.followings.insert(user)
                            users.append(user)
                        }
                        _ = try? DataManager.defaultManager.saveChanges()
                        success?(users)
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchFollowers(page page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Follower List",
            parameters: [
                "uid": id,
                "type": "fans",
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    if Int(msr_object: data["total_rows"]!!) > 0 {
                        var users = [User]()
                        for value in data["rows"] as! [NSDictionary] {
                            let userID = Int(msr_object: value["uid"])!
                            let user = User.cachedObjectWithID(userID)
                            user.name = value["user_name"] as? String
                            user.avatarURL = value["avatar_file"] as? String
                            user.signature = value["signature"] as? String
                            self_.followers.insert(user)
                            users.append(user)
                        }
                        _ = try? DataManager.defaultManager.saveChanges()
                        success?(users)
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchTopics(page page: Int, count: Int, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Topic List",
            parameters: [
                "uid": id,
                "page": page
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    if Int(msr_object: data["total_rows"]!!) > 0 {
                        var topics = [Topic]()
                        for value in data["rows"] as! [NSDictionary] {
                            let topicID = Int(msr_object: value["topic_id"])!
                            let topic = Topic.cachedObjectWithID(topicID)
                            topic.title = value["topic_title"] as? String
                            topic.introduction = value["topic_description"] as? String
                            topic.imageURL = value["topic_pic"] as? String
                            self_.topics.insert(topic)
                            topics.append(topic)
                        }
                        _ = try? DataManager.defaultManager.saveChanges()
                        success?(topics)
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchQuestions(page page: Int, count: Int, success: (([Question]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Question List",
            parameters: [
                "actions":101,
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                        let questionsData: [NSDictionary]
                        if data["rows"] is NSArray {
                            questionsData = data["rows"] as! [NSDictionary]
                        } else {
                            questionsData = [data["rows"] as! NSDictionary]
                        }
                        var questions = [Question]()
                        for questionData in questionsData {
                            let questionInfo = questionData["question_info"] as! NSDictionary
                            let questionID = Int(msr_object: questionInfo["question_id"])!
                            let question = Question.cachedObjectWithID(questionID)
                            question.user = self
                            question.title = (questionInfo["question_content"] as! String)
                            question.body = (questionInfo["message"] as? String)
                            question.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: questionInfo["add_time"])!)
                            self_.questions.insert(question)
                            questions.append(question)
                        }
                        _ = try? DataManager.defaultManager.saveChanges()
                        success?(questions)
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchAnswers(page page: Int, count: Int, success: (([Answer]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Answer List",
            parameters: [
                "actions":201,
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                        let answersData: [NSDictionary]
                        if data["rows"] is NSDictionary {
                            answersData = [data["rows"] as! NSDictionary]
                        } else {
                            answersData = data["rows"] as! [NSDictionary]
                        }
                        var answers = [Answer]()
                        for answerData in answersData {
                            let answerInfo = answerData["answer_info"] as! NSDictionary
                            let questionInfo = answerData["question_info"] as! NSDictionary
                            let answerID = Int(msr_object: answerInfo["answer_id"])!
                            let questionID = Int(msr_object: questionInfo["question_id"])!
                            let answer = Answer.cachedObjectWithID(answerID)
                            answer.question = Question.cachedObjectWithID(questionID)
                            answer.user = self
                            answer.user?.avatarURL = answerData["avatar_file"] as? String
                            answer.body = (answerInfo["answer_content"] as! String)
                            answer.agreementCount = Int(msr_object: answerInfo["agree_count"])
                            answer.question!.title = (questionInfo["question_content"] as! String)
                            self_.answers.insert(answer)
                            answers.append(answer)
                        }
                        _ = try? DataManager.defaultManager.saveChanges()
                        success?(answers)
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchArticles(page page: Int, count: Int, success: (([Article]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Article List",
            parameters: [
                "actions":501,
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                        let articlesData: [NSDictionary]
                        if data["rows"] is NSDictionary {
                            articlesData = [data["rows"] as! NSDictionary]
                        } else {
                            articlesData = data["rows"] as! [NSDictionary]
                        }
                        var articles = [Article]()
                        for articleData in articlesData {
                            let articleInfo = articleData["article_info"] as! NSDictionary
                            let articleID = Int(msr_object: articleInfo["id"])!
                            let article: Article = Article.cachedObjectWithID(articleID)
                            article.user = self
                            article.title = (articleInfo["title"] as! String)
                            article.body = (articleInfo["message"] as! String)
                            article.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: articleData["add_time"])!)
                            self_.articles.insert(article)
                            articles.append(article)
                        }
                        _ = try? DataManager.defaultManager.saveChanges()
                        success?(articles)
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    class func registerWithEmail(email: String, name: String, password: String, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("User Registration",
            parameters: [
                "user_name": name,
                "email": email,
                "password": password
            ],
            success: {
                data in
                let userID = Int(msr_object: data["uid"])!
                let user = User.cachedObjectWithID(userID)
                user.name = name
                let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!
                let cookiesData = NSKeyedArchiver.archivedDataWithRootObject(cookies)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(cookiesData, forKey: UserDefaultsCookiesKey)
                defaults.setObject(user.id, forKey: UserDefaultsUserIDKey)
                defaults.synchronize()
                _ = try? DataManager.defaultManager.saveChanges()
                self.loginWithCookiesAndCacheInStorage(success: success, failure: failure)
            },
            failure: failure)
    }
    
    class func loginWithCookiesAndCacheInStorage(success success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let data = defaults.objectForKey(UserDefaultsCookiesKey) as? NSData
        let userID = defaults.objectForKey(UserDefaultsUserIDKey) as? NSNumber
        if data == nil || userID == nil {
            let userInfo = [
                NSLocalizedDescriptionKey: "Could not find any cookies or cache in storage.",
                NSLocalizedFailureReasonErrorKey: "You've never logged in before or cookies and cache have been cleared."
            ]
            failure?(NSError(
                domain: NetworkManager.defaultManager!.website,
                code: NetworkManager.defaultManager!.internalErrorCode.integerValue,
                userInfo: userInfo)) // Needs specification
        } else {
            let cookies = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! [NSHTTPCookie]
            let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in cookies {
                storage.setCookie(cookie)
            }
            do {
                let user = try DataManager.defaultManager?.fetch("User", ID: userID!) as! User
                success?(user)
                
            } catch let error as NSError {
                let userInfo = [
                    NSLocalizedDescriptionKey: "Cookies and user ID were found, but no such user in cache.",
                    NSLocalizedFailureReasonErrorKey: "Caches have been cleared before.",
                    NSLocalizedRecoverySuggestionErrorKey: "By accessing \"User Basic Information\" with cookies in header, you can get the basic infomation of current user. Cookies have been set into header.",
                    NSUnderlyingErrorKey: error
                ]
                failure?(NSError(
                    domain: NetworkManager.defaultManager!.website,
                    code: NetworkManager.defaultManager!.internalErrorCode.integerValue,
                    userInfo: userInfo))
            }
        }
    }
    
    class func loginWithName(name: String, password: String, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.clearCookies()
        NetworkManager.defaultManager!.POST("User Login",
            parameters: [
                "user_name": name.stringByRemovingPercentEncoding!,
                "password": password.stringByRemovingPercentEncoding!
            ],
            success: {
                data in
                let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!
                let cookiesData = NSKeyedArchiver.archivedDataWithRootObject(cookies)
                let user = User.cachedObjectWithID(Int(msr_object: (data as! NSDictionary)["uid"])!)
                user.name = data["user_name"] as? String
                user.avatarURL = data["avatar_file"] as? String
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(cookiesData, forKey: UserDefaultsCookiesKey)
                defaults.setObject(user.id, forKey: UserDefaultsUserIDKey)
                defaults.synchronize()
                _ = try? DataManager.defaultManager.saveChanges()
                self.loginWithCookiesAndCacheInStorage(success: success, failure: failure)
            },
            failure: failure)
    }
    
    // Needs to be modified
    func fetchProfile(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Basic Information",
            parameters: [
                "uid": id
            ],
            success: {
                [weak self] data in
                let value = data[0] as! NSDictionary
                if let self_ = self {
                    self_.name = value["user_name"] as? String
                    self_.genderValue = value["sex"] is NSNull ? Gender.Secret.rawValue : Int(msr_object: value["sex"])
                    let timeInterval = NSTimeInterval(msr_object: value["birthday"])
                    if timeInterval != nil {
                        self_.birthday = NSDate(timeIntervalSince1970: timeInterval!)
                    }
                    self_.jobID = Int(msr_object: value["job_id"])
                    self_.signature = value["signature"] as? String
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func updateProfileForCurrentUser(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let id = self.id
        let name = self.name
        let gender = self.gender!
        let signature = self.signature
        let birthday = self.birthday
        let fmt = NSDateFormatter()
        fmt.locale = NSLocale(localeIdentifier: "zh_CN")
        fmt.dateFormat = "yyyy"
        let birthdayY =  Int(msr_object: fmt.stringFromDate(birthday!))!
        fmt.dateFormat = "MM"
        let birthdayM =  Int(msr_object: fmt.stringFromDate(birthday!))!
        fmt.dateFormat = "dd"
        let birthdayD =  Int(msr_object: fmt.stringFromDate(birthday!))!
        var parameters: [String: AnyObject] = ["user_name": name!]
        parameters["sex"] = gender.rawValue
        parameters["signature"] = signature
        parameters["birthday_y"] = birthdayY
        parameters["birthday_m"] = birthdayM
        parameters["birthday_d"] = birthdayD
        NetworkManager.defaultManager!.POST("Update Profile",
            parameters: parameters,
            success: {
                data in
                if data as! String == "个人资料保存成功" {
                    User.currentUser!.id = id
                    User.currentUser!.name = name
                    User.currentUser!.gender = gender
                    User.currentUser!.signature = signature
                    User.currentUser!.birthday = birthday
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    private static var avatarUploadingOperation: AFHTTPRequestOperation?
    
    class func uploadAvatar(avatar: UIImage, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let maxLength: CGFloat = 256
            let scale = min(1, max(maxLength / avatar.size.width, maxLength / avatar.size.height))
            var image = avatar.msr_imageOfSize(CGSize(width: avatar.size.width * scale, height: avatar.size.height * scale))
            image = image.msr_imageByClippingToRect(CGRect(x: (image.size.width - maxLength) / 2, y: (image.size.height - maxLength), width: maxLength, height: maxLength))
            let jpeg = UIImageJPEGRepresentation(image, 1)
            dispatch_async(dispatch_get_main_queue()) {
                self.avatarUploadingOperation = NetworkManager.defaultManager!.request("Upload User Avatar",
                    GETParameters: [:],
                    POSTParameters: [:],
                    constructingBodyWithBlock: {
                        data in
                        data?.appendPartWithFileData(jpeg, name: "user_avatar", fileName: "avatar.jpg", mimeType: "image/png")
                        return
                    },
                    success: {
                        data in
                        User.avatarUploadingOperation = nil
                        User.currentUser?.avatar = image
                        User.currentUser?.avatarURL = (data["preview"] as! String)
                        _ = try? DataManager.defaultManager.saveChanges()
                        success?()
                    },
                    failure: {
                        error in
                        User.avatarUploadingOperation = nil
                        failure?(error)
                    })
            }
        }
    }
    
    class func cancleAvatarUploadingOperation() {
        avatarUploadingOperation?.cancel()
    }
    
    func toggleFollow(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("Follow User",
            parameters: [
                "uid": id
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    self_.following = (data["type"] as! String == "add")
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    private let imageView = UIImageView()
    
    func fetchAvatar(forced forced: Bool, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if avatarURL != nil {
            let request = NSMutableURLRequest(URL: NSURL(string: avatarURL!)!)
            request.addValue("image/*", forHTTPHeaderField:"Accept")
            if forced {
                (UIImageView.sharedImageCache() as! NSCache).removeObjectForKey(request.URL!.absoluteString)
            }
            imageView.setImageWithURLRequest(request,
                placeholderImage: nil,
                success: {
                    [weak self] request, response, image in
                    if let self_ = self {
                        if self_.avatar == nil || response != nil {
                            self_.avatar = image
                            _ = try? DataManager.defaultManager.saveChanges()
                            success?()
                        } else {
                            failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                        }
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                },
                failure: {
                    _, _, error in
                    failure?(error)
                    return
            })
        } else {
            failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
        }
    }
    
    func fetchRelatedActions(page page: Int, count: Int, success: (([Action]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Home List",
            parameters: [
                "page": page - 1,
                "per_page": count
            ],
            success: {
                data in
                let rows = data["total_rows"] as! Int
                if rows > 0 {
                    var actions = [Action]()
                    let objects = data["rows"] as! [[String: AnyObject]]
                    for object in objects {
                        let typeID = ActionTypeID(rawValue: Int(msr_object: object["associate_action"])!)
                        if typeID == nil { print("ActionTypeID got a nil"); continue }
                        var action_: Action!
                        switch typeID! {
                        case .AnswerAgreement:
                            let action = AnswerAgreementAction.cachedObjectWithID(Int(msr_object: object["history_id"]!)!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            if let userInfo = object["user_info"] as? [String: AnyObject] {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                                action.user!.name = (userInfo["user_name"] as! String)
                                action.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                action.user = nil
                            }
                            let answerInfo = object["answer_info"] as! NSDictionary
                            action.answer = Answer.cachedObjectWithID(Int(msr_object: answerInfo["answer_id"])!)
                            action.answer!.body = (answerInfo["answer_content"] as! String)
                            action.answer!.agreementCount = (answerInfo["agree_count"] as! NSNumber)
                            /// @TODO: [Bug][Back-End] object["question_info"] is NSNull
                            if let questionInfo = object["question_info"] as? NSDictionary {
                                action.answer!.question = Question.cachedObjectWithID(Int(msr_object: questionInfo["question_id"])!)
                                action.answer!.question!.title = (questionInfo["question_content"] as! String)
                            } else {
                                action.answer!.question = Question.cachedObjectWithID(Int(msr_object: answerInfo["question_id"])!)
                                action.answer!.question!.title = "[问题已被删除]"
                            }
                            break
                        case .QuestionFocusing:
                            let action = QuestionFocusingAction.cachedObjectWithID(Int(msr_object: object["history_id"])!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            if let userInfo = object["user_info"] as? NSDictionary {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                                action.user!.name = (userInfo["user_name"] as! String)
                                action.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                action.user = nil
                            }
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.question = Question.cachedObjectWithID(Int(msr_object: questionInfo["question_id"])!)
                            action.question!.title = (questionInfo["question_content"] as! String)
                            break
                        case .QuestionPublishment:
                            let action = QuestionPublishmentAction.cachedObjectWithID(Int(msr_object: object["history_id"])!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            if let userInfo = object["user_info"] as? NSDictionary {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                                action.user!.name = (userInfo["user_name"] as! String)
                                action.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                action.user = nil
                            }
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.question = Question.cachedObjectWithID(Int(msr_object: questionInfo["question_id"])!)
                            action.question!.title = (questionInfo["question_content"] as! String)
                            action.question!.user = action.user
                            break
                        case .ArticleAgreement:
                            let action = ArticleAgreementAction.cachedObjectWithID(Int(msr_object: object["history_id"])!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            if let userInfo = object["user_info"] as? NSDictionary {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                                action.user!.name = (userInfo["user_name"] as! String)
                                action.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                action.user = nil
                            }
                            let articleInfo = object["article_info"] as! NSDictionary
                            action.article = Article.cachedObjectWithID(Int(msr_object: articleInfo["id"])!)
                            action.article!.title = (articleInfo["title"] as! String)
                            break
                        case .Answer:
                            let action = AnswerAction.cachedObjectWithID(Int(msr_object: object["history_id"])!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            if let userInfo = object["user_info"] as? NSDictionary {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                                action.user!.name = (userInfo["user_name"] as! String)
                                action.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                action.user = nil
                            }
                            let answerInfo = object["answer_info"] as! NSDictionary
                            action.answer = Answer.cachedObjectWithID(Int(msr_object: answerInfo["answer_id"])!)
                            action.answer!.body = (answerInfo["answer_content"] as! String)
                            action.answer!.agreementCount = (answerInfo["agree_count"] as! NSNumber)
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.answer!.question = Question.cachedObjectWithID(Int(msr_object: questionInfo["question_id"])!)
                            action.answer!.question!.title = (questionInfo["question_content"] as! String)
                            action.answer!.user = action.user
                            break
                        case .ArticlePublishment:
                            let action = ArticlePublishmentAction.cachedObjectWithID(Int(msr_object: object["history_id"])!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            if let userInfo = object["user_info"] as? NSDictionary {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                                action.user!.name = (userInfo["user_name"] as! String)
                                action.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                action.user = nil
                            }
                            let articleInfo = object["article_info"] as! NSDictionary
                            action.article = Article.cachedObjectWithID(Int(msr_object: articleInfo["id"])!)
                            action.article!.title = (articleInfo["title"] as! String)
                            action.article!.user = action.user
                            break
                        case .ArticleCommentary:
                            let action = ArticleCommentaryAction.cachedObjectWithID(Int(msr_object: object["history_id"]!)!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            if let userInfo = object["user_info"] as? [String: AnyObject] {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                                action.user!.id = Int(msr_object: userInfo["uid"])!
                                action.user!.name = (userInfo["user_name"] as! String)
                                action.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                action.user = nil
                            }
                            let commentInfo = object["comment_info"] as! [String: AnyObject]
                            action.comment = ArticleComment.cachedObjectWithID(Int(msr_object: commentInfo["id"]!)!)
                            action.comment!.body = commentInfo["message"] as? String
                            action.comment!.agreementCount = Int(msr_object: commentInfo["votes"]!)
                            if let atID = Int(msr_object: commentInfo["at_uid"]) {
                                if atID != 0 {
                                    action.comment!.atUser = User.cachedObjectWithID(atID)
                                }
                            }
                            let articleInfo = object["article_info"] as! [String: AnyObject]
                            action.comment!.article = Article.cachedObjectWithID(Int(msr_object: articleInfo["id"])!)
                            action.comment!.article!.title = (articleInfo["title"] as! String)
                            action.comment!.article!.body = (articleInfo["message"] as! String)
                            break
                        }
                        actions.append(action_)
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?(actions)
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    override func didChangeValueForKey(key: String) {
        super.didChangeValueForKey(key)
        if isCurrentUser {
            NSNotificationCenter.defaultCenter().postNotificationName(CurrentUserPropertyDidChangeNotificationName, object: nil, userInfo: [KeyUserInfoKey: key])
        }
    }
    
}
