//
//  User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import CoreData

let UserDefaultsCookiesKey = "WeCenterMobile_DefaultCookies"
let UserDefaultsUserIDKey = "WeCenterMobile_DefaultUserID"

class User: NSManagedObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var answerCount: NSNumber?
    @NSManaged var answerFavoriteCount: NSNumber?
    @NSManaged var avatarData: NSData?
    @NSManaged var avatarURI: String?
    @NSManaged var birthday: NSNumber?
    @NSManaged var followerCount: NSNumber?
    @NSManaged var followingCount: NSNumber?
    @NSManaged var genderValue: NSNumber?
    @NSManaged var id: NSNumber
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
    
    var followed: Bool? = nil
    
    var avatarURL: String? {
        return (avatarURI == nil) ? nil : NetworkManager.defaultManager!.website + NetworkManager.defaultManager!.paths["User Avatar"]! + avatarURI!
    }
    
    class func get(#ID: NSNumber, error: NSErrorPointer) -> User? {
        return DataManager.defaultManager!.fetch("User", ID: ID, error: error) as? User
    }
    
    class func fetch(#ID: NSNumber, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Extra Information",
            parameters: [
                "uid": ID
            ],
            success: {
                data in
                let data = data as! NSDictionary
                let user = DataManager.defaultManager!.autoGenerate("User", ID: ID) as! User
                user.id = ID
                user.name = data["user_name"] as? String
                user.avatarURI = data["avatar_file"] as? String
                user.followerCount = Int(msr_object: data["fans_count"])
                user.followingCount = Int(msr_object: data["friend_count"])
                user.questionCount = Int(msr_object: data["question_count"])
                user.answerCount = Int(msr_object: data["answer_count"])
                user.topicFocusCount = Int(msr_object: data["topic_focus_count"])
                user.agreementCount = Int(msr_object: data["agree_count"])
                user.thankCount = Int(msr_object: data["thanks_count"])
                user.answerFavoriteCount = Int(msr_object: data["answer_favorite_count"])
                user.followed = (data["has_focus"] as! NSNumber == 1)
                success?(user)
            },
            failure: failure)
    }
    
    func fetchFollowings(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Following List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    for value in data["rows"] as! [NSDictionary] {
                        let userID = Int(msr_object: value["uid"])
                        let user = DataManager.defaultManager!.autoGenerate("User", ID: userID!) as! User
                        user.name = value["user_name"] as? String
                        user.avatarURI = value["avatar_file"] as? String
                        user.signature = value["signature"] as? String
                        self.followings.insert(user)
                    }
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchFollowers(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Follower List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    for value in data["rows"] as! [NSDictionary] {
                        let userID = Int(msr_object: value["uid"])!
                        let user = DataManager.defaultManager!.autoGenerate("User", ID: userID) as! User
                        user.name = value["user_name"] as? String
                        user.avatarURI = value["avatar_file"] as? String
                        user.signature = value["signature"] as? String
                        self.followers.insert(user)
                    }
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchTopics(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Topic List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    for value in data["rows"] as! [NSDictionary] {
                        let topicID = Int(msr_object: value["topic_id"])!
                        let topic = DataManager.defaultManager!.autoGenerate("Topic", ID: topicID) as! Topic
                        topic.title = value["topic_title"] as? String
                        topic.introduction = value["topic_description"] as? String
                        topic.imageURI = value["topic_pic"] as? String
                        self.topics.insert(topic)
                    }
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
                return
            },
            failure: failure)
    }
    
    func fetchQuestions(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("User Question List",
            parameters: [
                "uid": id
            ],
            success: {
                data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    var questionsData = [NSDictionary]()
                    if data["rows"] is NSDictionary {
                        questionsData = [data["rows"] as! NSDictionary]
                    } else {
                        questionsData = data["rows"] as! [NSDictionary]
                    }
                    for questionData in questionsData {
                        let questionID = Int(msr_object: questionData["id"])!
                        let question = DataManager.defaultManager!.autoGenerate("Question", ID: questionID) as! Question
                        question.user = self
                        question.title = questionData["title"] as? String
                        question.body = questionData["detail"] as? String
                        self.questions.insert(question)
                    }
                }
                success?()
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
            if let user = get(ID: userID!, error: &error) {
                success?(user)
            } else {
                var userInfo = [
                    NSLocalizedDescriptionKey: "Cookies and user ID were found, but no such user in cache.",
                    NSLocalizedFailureReasonErrorKey: "Caches have been cleared before.",
                    NSLocalizedRecoverySuggestionErrorKey: "By accessing \"User Basic Information\" with cookies in header, you can get the basic infomation of current user. Cookies have been set into header."
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
                "user_name": name.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
                "password": password.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            ],
            success: {
                data in
                let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as! [NSHTTPCookie]
                let cookiesData = NSKeyedArchiver.archivedDataWithRootObject(cookies)
                let user = DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: (data as! NSDictionary)["uid"])!) as! User
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
                data in
                let value = data[0] as! NSDictionary
                self.name = value["user_name"] as? String
                self.genderValue = value["sex"] is NSNull ? Gender.Secret.rawValue : Int(msr_object: value["sex"])
                self.birthday = Int(msr_object: value["birthday"])
                self.jobID = Int(msr_object: value["job_id"])
                self.signature = value["signature"] as? String
                success?()
            },
            failure: failure)
    }
    
    func toggleFollow(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Follow User",
            parameters: [
                "uid": id
            ],
            success: {
                data in
                self.followed = (data["type"] as! String == "add")
                success?()
            },
            failure: failure)
    }
    
    private let imageView = UIImageView()
    
    func fetchAvatar(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if avatarURL != nil {
            imageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: avatarURL!)!),
                placeholderImage: nil,
                success: {
                    request, response, image in
                    self.avatar = image
                    success?()
                    return
                },
                failure: {
                    request, response, error in
                    failure?(error)
                    return
            })
        } else {
            failure?(NSError()) // Needs specification
        }
    }
    
    func fetchRelatedActions(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Home List",
            parameters: [
                "page": page - 1,
                "per_page": count
            ],
            success: {
                data in
                let rows = data["total_rows"] as! Int
                if rows > 0 {
                    let objects = data["rows"] as! [[String: AnyObject]]
                    for object in objects {
                        let typeID = ActionTypeID(rawValue: Int(msr_object: object["associate_action"])!)!
                        var action_: Action!
                        switch typeID {
                        case .AnswerAgreement:
                            let action = DataManager.defaultManager!.autoGenerate("AnswerAgreementAction", ID: Int(msr_object: object["history_id"]!)!) as! AnswerAgreementAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo!["uid"])!) as! User)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["user_name"] as! String)
                            } else {
                                action.user = nil
                            }
                            let answerInfo = object["answer_info"] as! NSDictionary
                            action.answer = DataManager.defaultManager!.autoGenerate("Answer", ID: Int(msr_object: answerInfo["answer_id"])!) as! Answer
                            action.answer.question = (DataManager.defaultManager!.autoGenerate("Question", ID: Int(msr_object: answerInfo["question_id"])!) as! Question)
                            action.answer.body = (answerInfo["answer_content"] as! String)
                            action.answer.agreementCount = (answerInfo["agree_count"] as! NSNumber)
                            action.answer.evaluation = Answer.Evaluation(rawValue: Int(msr_object: answerInfo["agree_status"])!)!
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.answer.question = (DataManager.defaultManager!.autoGenerate("Question", ID: Int(msr_object: questionInfo["question_id"])!) as! Question)
                            action.answer.question!.title = (questionInfo["question_content"] as! String)
                            break
                        case .QuestionFocusing:
                            let action = DataManager.defaultManager!.autoGenerate("QuestionFocusingAction", ID: Int(msr_object: object["history_id"])!) as! QuestionFocusingAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo!["uid"])!) as! User)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.question = DataManager.defaultManager!.autoGenerate("Question", ID: Int(msr_object: questionInfo["question_id"])!) as! Question
                            action.question.title = (questionInfo["question_content"] as! String)
                            break
                        case .QuestionPublishment:
                            let action = DataManager.defaultManager!.autoGenerate("QuestionPublishmentAction", ID: Int(msr_object: object["history_id"])!) as! QuestionPublishmentAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo!["uid"])!) as! User)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.question = DataManager.defaultManager!.autoGenerate("Question", ID: Int(msr_object: questionInfo["question_id"])!) as! Question
                            action.question.title = (questionInfo["question_content"] as! String)
                            action.question.user = action.user
                            break
                        case .ArticleAgreement:
                            let action = DataManager.defaultManager!.autoGenerate("ArticleAgreementAction", ID: Int(msr_object: object["history_id"])!) as! ArticleAgreementAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo!["uid"])!) as! User)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let articleInfo = object["article_info"] as! NSDictionary
                            action.article = DataManager.defaultManager!.autoGenerate("Article", ID: Int(msr_object: articleInfo["id"])!) as! Article
                            action.article.title = (articleInfo["title"] as! String)
                            break
                        case .Answer:
                            let action = DataManager.defaultManager!.autoGenerate("AnswerAction", ID: Int(msr_object: object["history_id"])!) as! AnswerAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo!["uid"])!) as! User)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let answerInfo = object["answer_info"] as! NSDictionary
                            action.answer = DataManager.defaultManager!.autoGenerate("Answer", ID: Int(msr_object: answerInfo["answer_id"])!) as! Answer
                            action.answer.body = (answerInfo["answer_content"] as! String)
                            action.answer.agreementCount = (answerInfo["agree_count"] as! NSNumber)
                            action.answer.evaluation = Answer.Evaluation(rawValue: Int(msr_object: answerInfo["agree_status"])!)!
                            let questionInfo = object["question_info"] as! NSDictionary
                            action.answer.question = (DataManager.defaultManager!.autoGenerate("Question", ID: Int(msr_object: questionInfo["question_id"])!) as! Question)
                            action.answer.question!.title = (questionInfo["question_content"] as! String)
                            action.answer.user = action.user
                            break
                        case .ArticlePublishment:
                            let action = DataManager.defaultManager!.autoGenerate("ArticlePublishmentAction", ID: Int(msr_object: object["history_id"])!) as! ArticlePublishmentAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as! NSNumber).doubleValue)
                            let userInfo = object["user_info"] as? NSDictionary
                            if userInfo != nil {
                                action.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo!["uid"])!) as! User)
                                action.user!.name = (userInfo!["user_name"] as! String)
                                action.user!.avatarURI = (userInfo!["avatar_file"] as! String)
                            } else {
                                action.user = nil
                            }
                            let articleInfo = object["article_info"] as! NSDictionary
                            action.article = DataManager.defaultManager!.autoGenerate("Article", ID: Int(msr_object: articleInfo["id"])!) as! Article
                            action.article.title = (articleInfo["title"] as! String)
                            action.article.user = action.user
                            break
                        default:
                            break
                        }
                    }
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }

}
