//
//  Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Topic: NSManagedObject {

    @NSManaged var focusCount: NSNumber?
    @NSManaged var id: NSNumber
    @NSManaged var imageURI: String?
    @NSManaged var introduction: String?
    @NSManaged var title: String?
    @NSManaged var articles: NSSet
    @NSManaged var questions: NSSet
    @NSManaged var users: NSSet
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
        let topic = DataManager.defaultManager!.autoGenerate("Topic", ID: ID) as! Topic
        NetworkManager.defaultManager!.GET("Topic Detail",
            parameters: [
                "uid": appDelegate.currentUser!.id,
                "topic_id": ID
            ],
            success: {
                data in
                topic.title = data["topic_title"] as? String
                topic.introduction = data["topic_description"] as? String
                topic.imageURI = data["topic_pic"] as? String
                topic.focusCount = (data["focus_count"] as! NSString).integerValue
                topic.focused = (data["has_focus"] as! NSNumber == 1)
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
                data in
                self.focused = false
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
                data in
                self.focused = true
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
                data in
                if (data["total_rows"] as! NSNumber).integerValue > 0 {
                    var answers = [Answer]()
                    for value in data["rows"] as! [NSDictionary] {
                        let questionValue = value["question_info"] as! NSDictionary
                        var questionArray = self.questions.allObjects as! [Question]
                        let questionID = questionValue["question_id"] as! NSNumber
                        var question: Question! = questionArray.filter({ $0.id == questionID }).first
                        if question == nil {
                            question = DataManager.defaultManager!.autoGenerate("Question", ID: questionID) as? Question
                            questionArray.append(question)
                        }
                        question.title = questionValue["question_content"] as? String
                        self.questions = NSSet(array: questionArray)
                        let answerValue = value["answer_info"] as! NSDictionary
                        var answerArray = question.answers.allObjects as! [Answer]
                        let answerID = answerValue["answer_id"] as! NSNumber
                        var answer: Answer! = answerArray.filter({ $0.id == answerID }).first
                        if answer == nil {
                            answer = DataManager.defaultManager!.autoGenerate("Answer", ID: answerID) as? Answer
                            answerArray.append(answer)
                        }
                        answer.body = answerValue["answer_content"] as? String
                        answer.agreementCount = answerValue["agree_count"] as? NSNumber
                        question.answers = NSSet(array: answerArray)
                        let userID = answerValue["uid"] as! NSNumber
                        answer.user = (DataManager.defaultManager!.autoGenerate("User", ID: userID) as! User)
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

}
