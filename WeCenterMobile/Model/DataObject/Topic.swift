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
        return (imageURI == nil) ? nil : NetworkManager.defaultManager!.website + NetworkManager.defaultManager!.paths["Topic Image"]! + imageURI!
    }
    
    var image: UIImage? {
        get {
            return (imageData == nil) ? nil : UIImage(data: imageData!)
        }
        set {
            imageData = UIImagePNGRepresentation(newValue)
        }
    }
    
    class func get(#ID: NSNumber, error: NSErrorPointer) -> Topic? {
        return DataManager.defaultManager!.fetch("Topic", ID: ID, error: error) as? Topic
    }
    
    class func fetch(#ID: NSNumber, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Topic Detail",
            parameters: [
                "uid": User.currentUser!.id,
                "topic_id": ID
            ],
            success: {
                data in
                let topic = Topic.cachedObjectWithID(ID)
                topic.title = data["topic_title"] as? String
                topic.introduction = data["topic_description"] as? String
                topic.imageURI = data["topic_pic"] as? String
                topic.focusCount = Int(msr_object: data["focus_count"]!!)
                topic.focused = Int(msr_object: data["has_focus"]) == 1
                success?(topic)
            },
            failure: failure)
    }
    
    func toggleFocus(#userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if focused != nil {
            if focused! {
                cancleFocus(userID: userID, success: success, failure: failure)
            } else {
                focus(userID: userID, success: success, failure: failure)
            }
        } else {
            failure?(NSError()) // Needs specification
        }
    }
    
    func cancleFocus(#userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("Focus Topic",
            parameters: [
                "uid": userID,
                "topic_id": id,
                "type": "cancel"
            ],
            success: {
                [weak self] data in
                self?.focused = false
                success?()
            },
            failure: failure)
    }
    
    func focus(#userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("Focus Topic",
            parameters: [
                "uid": userID,
                "topic_id": id,
                "type": "focus"
            ],
            success: {
                [weak self] data in
                self?.focused = true
                success?()
            },
            failure: failure)
    }
    
    func fetchOutstandingAnswers(#success: (([Answer]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Topic Outstanding Answer List",
            parameters: [
                "id": id
            ],
            success: {
                [weak self] data in
                if Int(msr_object: data["total_rows"]!!) > 0 {
                    var answers = [Answer]()
                    for value in data["rows"] as! [NSDictionary] {
                        let questionValue = value["question_info"] as! NSDictionary
                        let questionID = questionValue["question_id"] as! NSNumber
                        let question = Question.cachedObjectWithID(questionID)
                        self?.questions.insert(question)
                        question.title = questionValue["question_content"] as? String
                        let answerValue = value["answer_info"] as! NSDictionary
                        let answerID = answerValue["answer_id"] as! NSNumber
                        let answer = Answer.cachedObjectWithID(answerID)
                        question.answers.insert(answer)
                        answer.body = answerValue["answer_content"] as? String
                        answer.agreementCount = answerValue["agree_count"] as? NSNumber
                        let userID = answerValue["uid"] as! NSNumber
                        answer.user = User.cachedObjectWithID(userID)
                        answer.user!.avatarURI = answerValue["avatar_file"] as? String
                        answers.append(answer)
                    }
                    success?(answers)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    private let imageView = UIImageView()
    
    func fetchImage(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
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

}
