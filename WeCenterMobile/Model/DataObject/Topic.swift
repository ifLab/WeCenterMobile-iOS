//
//  Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFNetworking
import CoreData
import UIKit

enum TopicObjectListType: String {
    case Month = "month"
    case Week = "weeek"
    case All = "all"
    case Focus = "focus"
}

class Topic: DataObject {

    @NSManaged var focusCount: NSNumber?
    @NSManaged var imageURI: String?
    @NSManaged var introduction: String?
    @NSManaged var title: String?
    @NSManaged var articles: Set<Article>
    @NSManaged var questions: Set<Question>
    @NSManaged var users: Set<User>
    @NSManaged var imageData: NSData?
    
    var focused: Bool? = nil
    
    var imageURL: String? {
        get {
            return (imageURI == nil) ? nil : NetworkManager.defaultManager!.website + NetworkManager.defaultManager!.paths["Topic Image"]! + imageURI!
        }
        set {
            if let replacedString = newValue?.stringByReplacingOccurrencesOfString(NetworkManager.defaultManager!.website + NetworkManager.defaultManager!.paths["Topic Image"]!, withString: "") {
                if replacedString != newValue {
                    imageURI = replacedString
                } else {
                    imageURI = nil
                }
            } else {
                imageURI = nil
            }
        }
    }
    
    var image: UIImage? {
        get {
            return (imageData == nil) ? nil : UIImage(data: imageData!)
        }
        set {
            imageData = newValue == nil ? nil : UIImagePNGRepresentation(newValue!)
        }
    }
    
    class func fetch(ID ID: NSNumber, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Topic Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let topic = Topic.cachedObjectWithID(ID)
                topic.title = data["topic_title"] as? String
                topic.introduction = data["topic_description"] as? String
                topic.imageURI = data["topic_pic"] as? String
                topic.focusCount = Int(msr_object: data["focus_count"]!!)
                topic.focused = Int(msr_object: data["has_focus"]) == 1
                _ = try? DataManager.defaultManager.saveChanges()
                success?(topic)
            },
            failure: failure)
    }
    
    class func fetchHotTopic(page page: Int, count: Int, type: TopicObjectListType, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        var parameters: [String: AnyObject] = [
        "page": page,
        "count": count
        ]
        if type.rawValue != "all" {
            parameters["day"] = type.rawValue
        }
        NetworkManager.defaultManager!.GET("Hot Topic List",
            parameters: parameters,
            success: {
                data in
                if Int(msr_object: data["total_rows"]) > 0 {
                    var topics = [Topic]()
                    for object in data["rows"] as! [[String: AnyObject]] {
                        let topic = Topic.cachedObjectWithID(Int(msr_object: object["topic_id"]!)!)
                        topic.title = object["topic_title"] as? String
                        topic.introduction = object["topic_description"] as? String
                        topic.imageURI = object["topic_pic"] as? String
                        topic.focusCount = Int(msr_object: object["focus_count"]!)!
                        topics.append(topic)
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?(topics)
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func toggleFocus(userID userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if focused != nil {
            if focused! {
                cancleFocus(userID: userID, success: success, failure: failure)
            } else {
                focus(userID: userID, success: success, failure: failure)
            }
        } else {
            failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
        }
    }
    
    func cancleFocus(userID userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("Focus Topic",
            parameters: [
                "uid": userID,
                "topic_id": id,
                "type": "cancel"
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    self_.focused = false
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func focus(userID userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("Focus Topic",
            parameters: [
                "uid": userID,
                "topic_id": id,
                "type": "focus"
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    self_.focused = true
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchOutstandingAnswers(success success: (([Answer]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Topic Outstanding Answer List",
            parameters: [
                "topic_id": id,
                "page": 1
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    if Int(msr_object: data["total_rows"]!!) > 0 {
                        var answers = [Answer]()
                        for value in data["rows"] as! [NSDictionary] {
                            let questionValue = value["question_info"] as! NSDictionary
                            let questionID = questionValue["question_id"] as! NSNumber
                            let question = Question.cachedObjectWithID(questionID)
                            self_.questions.insert(question)
                            question.title = questionValue["question_content"] as? String
                            let answerValue = value["answer_info"] as! NSDictionary
                            let answerID = answerValue["answer_id"] as! NSNumber
                            let answer = Answer.cachedObjectWithID(answerID)
                            question.answers.insert(answer)
                            answer.body = answerValue["answer_content"] as? String
                            answer.agreementCount = answerValue["agree_count"] as? NSNumber
                            let userValue = value["user_info"] as! NSDictionary
                            let userID = userValue["uid"] as! NSNumber
                            answer.user = User.cachedObjectWithID(userID)
                            answer.user!.avatarURL = userValue["avatar_file"] as? String
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
    
    private let imageView = UIImageView()
    
    func fetchImage(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if imageURL != nil {
            let request = NSMutableURLRequest(URL: NSURL(string: imageURL!)!)
            request.addValue("image/*", forHTTPHeaderField:"Accept")
            imageView.setImageWithURLRequest(request,
                placeholderImage: nil,
                success: {
                    [weak self] request, response, image in
                    if self?.image == nil || response != nil {
                        self?.image = image
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                },
                failure: {
                    request, response, error in
                    failure?(error)
                    return
                })
        } else {
            failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
        }
    }

}
