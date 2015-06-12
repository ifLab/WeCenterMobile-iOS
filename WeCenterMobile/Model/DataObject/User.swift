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
            avatarData = UIImagePNGRepresentation(newValue)
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
    
    class func fetch(#ID: NSNumber, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
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
                user.avatarURI = data["avatar_file"] as? String
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
                success?(user)
            },
            failure: failure)
    }
    
    func fetchFollowings(#page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Following List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    var users = [User]()
                    for value in data["rows"] as! [NSDictionary] {
                        let userID = Int(msr_object: value["uid"])
                        let user = User.cachedObjectWithID(userID!)
                        user.name = value["user_name"] as? String
                        user.avatarURI = value["avatar_file"] as? String
                        user.signature = value["signature"] as? String
                        self?.followings.insert(user)
                        users.append(user)
                    }
                    success?(users)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchFollowers(#page: Int, count: Int, success: (([User]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Follower List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    var users = [User]()
                    for value in data["rows"] as! [NSDictionary] {
                        let userID = Int(msr_object: value["uid"])!
                        let user = User.cachedObjectWithID(userID)
                        user.name = value["user_name"] as? String
                        user.avatarURI = value["avatar_file"] as? String
                        user.signature = value["signature"] as? String
                        self?.followers.insert(user)
                        users.append(user)
                    }
                    success?(users)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchTopics(#page: Int, count: Int, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Topic List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    var topics = [Topic]()
                    for value in data["rows"] as! [NSDictionary] {
                        let topicID = Int(msr_object: value["topic_id"])!
                        let topic = Topic.cachedObjectWithID(topicID)
                        topic.title = value["topic_title"] as? String
                        topic.introduction = value["topic_description"] as? String
                        topic.imageURI = value["topic_pic"] as? String
                        self?.topics.insert(topic)
                        topics.append(topic)
                    }
                    success?(topics)
                } else {
                    failure?(NSError()) // Needs specification
                }
                return
            },
            failure: failure)
    }
    
    func fetchQuestions(#page: Int, count: Int, success: (([Question]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Question List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                    let questionsData: [NSDictionary]
                    if data["rows"] is NSDictionary {
                        questionsData = [data["rows"] as! NSDictionary]
                    } else {
                        questionsData = data["rows"] as! [NSDictionary]
                    }
                    var questions = [Question]()
                    for questionData in questionsData {
                        let questionID = Int(msr_object: questionData["id"])!
                        let question = Question.cachedObjectWithID(questionID)
                        question.user = self
                        question.title = (questionData["title"] as! String)
                        question.body = (questionData["detail"] as! String)
                        question.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: questionData["add_time"])!)
                        self?.questions.insert(question)
                        questions.append(question)
                    }
                    success?(questions)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchAnswers(#page: Int, count: Int, success: (([Answer]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Answer List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                [weak self] data in
                if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                    let answersData: [NSDictionary]
                    if data["rows"] is NSDictionary {
                        answersData = [data["rows"] as! NSDictionary]
                    } else {
                        answersData = data["rows"] as! [NSDictionary]
                    }
                    var answers = [Answer]()
                    for answerData in answersData {
                        let answerID = Int(msr_object: answerData["answer_id"])!
                        let questionID = Int(msr_object: answerData["question_id"])!
                        let answer = Answer.cachedObjectWithID(answerID)
                        answer.question = Question.cachedObjectWithID(questionID)
                        answer.user = self
                        answer.user?.avatarURI = answerData["avatar_file"] as? String
                        answer.body = (answerData["answer_content"] as! String)
                        answer.agreementCount = Int(msr_object: answerData["agree_count"])
                        answer.question!.title = (answerData["question_title"] as! String)
                        self?.answers.insert(answer)
                        answers.append(answer)
                    }
                    success?(answers)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchArticles(#page: Int, count: Int, success: (([Article]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Article List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count /// @TODO: [Bug][Back-End] Calculation error.
            ],
            success: {
                [weak self] data in
                if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                    let articlesData: [NSDictionary]
                    if data["rows"] is NSDictionary {
                        articlesData = [data["rows"] as! NSDictionary]
                    } else {
                        articlesData = data["rows"] as! [NSDictionary]
                    }
                    var articles = [Article]()
                    for articleData in articlesData {
                        let articleID = Int(msr_object: articleData["id"])!
                        let article: Article = Article.cachedObjectWithID(articleID)
                        article.user = self
                        article.title = (articleData["title"] as! String)
                        article.body = (articleData["message"] as! String)
                        article.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: articleData["add_time"])!)
                        self?.articles.insert(article)
                        articles.append(article)
                    }
                    success?(articles)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    class func loginWithCookiesAndCacheInStorage(#success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let data = defaults.objectForKey(UserDefaultsCookiesKey) as? NSData
        let userID = defaults.objectForKey(UserDefaultsUserIDKey) as? NSNumber
        var error: NSError? = nil
        if data == nil || userID == nil {
            var userInfo = [
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
            if let user = DataManager.defaultManager?.fetch("User", ID: userID!, error: &error) as? User {
                success?(user)
            } else {
                var userInfo: NSMutableDictionary = [
                    NSLocalizedDescriptionKey: "Cookies and user ID were found, but no such user in cache.",
                    NSLocalizedFailureReasonErrorKey: "Caches have been cleared before.",
                    NSLocalizedRecoverySuggestionErrorKey: "By accessing \"User Basic Information\" with cookies in header, you can get the basic infomation of current user. Cookies have been set into header."
                ]
                if error != nil {
                    userInfo[NSUnderlyingErrorKey] = error
                }
                failure?(NSError(
                    domain: NetworkManager.defaultManager!.website,
                    code: NetworkManager.defaultManager!.internalErrorCode.integerValue,
                    userInfo: userInfo as [NSObject: AnyObject]))
            }
        }
    }
    
    class func loginWithName(name: String, password: String, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.clearCookies()
        NetworkManager.defaultManager!.POST("User Login",
            parameters: [
                "user_name": name.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
                "password": password.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            ],
            success: {
                data in
                let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as! [NSHTTPCookie]
                let cookiesData = NSKeyedArchiver.archivedDataWithRootObject(cookies)
                let user = User.cachedObjectWithID(Int(msr_object: (data as! NSDictionary)["uid"])!)
                user.name = data["user_name"] as? String
                user.avatarURI = data["avatar_file"] as? String
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(cookiesData, forKey: UserDefaultsCookiesKey)
                defaults.setObject(user.id, forKey: UserDefaultsUserIDKey)
                defaults.synchronize()
                self.loginWithCookiesAndCacheInStorage(success: success, failure: failure)
            },
            failure: failure)
    }
    
    // Needs to be modified
    func fetchProfile(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
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
                }
                success?()
            },
            failure: failure)
    }
    
    func updateProfileForCurrentUser(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let id = self.id
        let name = self.name
        let gender = self.gender!
        let signature = self.signature
        let birthday = self.birthday
        var parameters: NSMutableDictionary = ["uid": id]
        parameters["user_name"] = name
        parameters["sex"] = gender.rawValue
        parameters["signature"] = signature
        parameters["birthday"] = birthday?.timeIntervalSince1970
        NetworkManager.defaultManager!.POST("Update Profile",
            parameters: parameters,
            success: {
                [weak self] data in
                if data as! String == "success" {
                    User.currentUser!.id = id
                    User.currentUser!.name = name
                    User.currentUser!.gender = gender
                    User.currentUser!.signature = signature
                    User.currentUser!.birthday = birthday
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    private static var avatarUploadingOperation: AFHTTPRequestOperation?
    
    class func uploadAvatar(avatar: UIImage, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let jpeg = UIImageJPEGRepresentation(avatar, 1)
            dispatch_async(dispatch_get_main_queue()) {
                self.avatarUploadingOperation = NetworkManager.defaultManager!.request("Upload User Avatar",
                    GETParameters: nil,
                    POSTParameters: nil,
                    constructingBodyWithBlock: {
                        data in
                        data?.appendPartWithFileData(jpeg, name: "user_avatar", fileName: "avatar.jpg", mimeType: "image/png")
                        return
                    },
                    success: {
                        data in
                        self.avatarUploadingOperation = nil
                        self.currentUser?.avatar = avatar
                        self.currentUser?.avatarURL = (data["preview"] as! String)
                        success?()
                        return
                    },
                    failure: {
                        error in
                        self.avatarUploadingOperation = nil
                        failure?(error)
                    })
            }
        }
    }
    
    class func cancleAvatarUploadingOperation() {
        avatarUploadingOperation?.cancel()
    }
    
    func toggleFollow(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Follow User",
            parameters: [
                "uid": id
            ],
            success: {
                [weak self] data in
                self?.following = (data["type"] as! String == "add")
                success?()
            },
            failure: failure)
    }
    
    private let imageView = UIImageView()
    
    func fetchAvatar(#forced: Bool, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if avatarURL != nil {
            let request = NSMutableURLRequest(URL: NSURL(string: avatarURL!)!)
            request.addValue("image/*", forHTTPHeaderField:"Accept")
            if forced {
                (UIImageView.sharedImageCache() as! NSCache).removeObjectForKey(request.URL!.absoluteString!)
            }
            imageView.setImageWithURLRequest(request,
                placeholderImage: nil,
                success: {
                    [weak self] request, response, image in
                    if self?.avatar == nil || response != nil {
                        self?.avatar = image
                    }
                    success?()
                    return
                },
                failure: {
                    [weak self] request, response, error in
                    failure?(error)
                    return
            })
        } else {
            failure?(NSError()) // Needs specification
        }
    }
    
    func fetchRelatedActions(#page: Int, count: Int, success: (([Action]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Home List",
            parameters: [
                "page": page - 1,
                "per_page": count
            ],
            success: {
                [weak self] data in
                let rows = data["total_rows"] as! Int
                if rows > 0 {
                    var actions = [Action]()
                    let objects = data["rows"] as! [[String: AnyObject]]
                    for object in objects {
                        let typeID = ActionTypeID(rawValue: Int(msr_object: object["associate_action"])!)!
                        var action_: Action!
                        switch typeID {
                        case .AnswerAgreement:
                            let action = AnswerAgreementAction.cachedObjectWithID(Int(msr_object: object["history_id"]!)!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo!["uid"])!)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let answerInfo = object["answer_info"] as! NSDictionary
                            action.answer = Answer.cachedObjectWithID(Int(msr_object: answerInfo["answer_id"])!)
                            action.answer!.question = Question.cachedObjectWithID(Int(msr_object: answerInfo["question_id"])!)
                            action.answer!.body = (answerInfo["answer_content"] as! String)
                            action.answer!.agreementCount = (answerInfo["agree_count"] as! NSNumber)
                            action.answer!.evaluation = Evaluation(rawValue: Int(msr_object: answerInfo["agree_status"])!)!
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
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo!["uid"])!)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
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
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo!["uid"])!)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
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
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo!["uid"])!)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
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
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo!["uid"])!)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let answerInfo = object["answer_info"] as! NSDictionary
                            action.answer = Answer.cachedObjectWithID(Int(msr_object: answerInfo["answer_id"])!)
                            action.answer!.body = (answerInfo["answer_content"] as! String)
                            action.answer!.agreementCount = (answerInfo["agree_count"] as! NSNumber)
                            action.answer!.evaluation = Evaluation(rawValue: Int(msr_object: answerInfo["agree_status"])!)!
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.answer!.question = Question.cachedObjectWithID(Int(msr_object: questionInfo["question_id"])!)
                            action.answer!.question!.title = (questionInfo["question_content"] as! String)
                            action.answer!.user = action.user
                            break
                        case .ArticlePublishment:
                            let action = ArticlePublishmentAction.cachedObjectWithID(Int(msr_object: object["history_id"])!)
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = User.cachedObjectWithID(Int(msr_object: userInfo!["uid"])!)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let articleInfo = object["article_info"] as! NSDictionary
                            action.article = Article.cachedObjectWithID(Int(msr_object: articleInfo["id"])!)
                            action.article!.title = (articleInfo["title"] as! String)
                            action.article!.user = action.user
                            break
                        default:
                            break
                        }
                        actions.append(action_)
                    }
                    success?(actions)
                } else {
                    failure?(NSError()) // Needs specification
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
