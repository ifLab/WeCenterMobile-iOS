//
//  Question.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFNetworking
import CoreData
import Foundation

class Question: DataObject {
    
    @NSManaged var attachmentKey: String?
    @NSManaged var body: String?
    @NSManaged var date: NSDate?
    @NSManaged var viewCount: NSNumber?
    @NSManaged var focusCount: NSNumber?
    @NSManaged var title: String?
    @NSManaged var updatedDate: NSDate?
    @NSManaged var answers: Set<Answer>
    @NSManaged var featuredObject: FeaturedQuestionAnswer?
    @NSManaged var questionFocusingActions: Set<QuestionFocusingAction>
    @NSManaged var questionPublishmentActions: Set<QuestionPublishmentAction>
    @NSManaged var topics: Set<Topic>
    @NSManaged var user: User?
    
    var focusing: Bool? = nil
    
    class func fetch(ID ID: NSNumber, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        let question = Question.cachedObjectWithID(ID)
        NetworkManager.defaultManager!.GET("Question Detail",
            parameters: [
                "id": ID,
                "sort": "DESC"/// @TODO 倒叙
            ],
            success: {
                data in
                let value = data["question_info"] as! NSDictionary
                question.id = Int(msr_object: value["question_id"])!
                question.title = value["question_content"] as? String
                question.body = value["question_detail"] as? String
                question.focusCount = Int(msr_object: value["focus_count"])
                question.focusing = (Int(msr_object: value["user_question_focus"]) == 1)
                
                for value in (data["answers"] as! [NSDictionary] ) {
                    let answerID = value["answer_id"] as! NSNumber
                    var answer: Answer! = question.answers.filter { $0.id == answerID }.first
                    if answer == nil {
                        answer = Answer.cachedObjectWithID(answerID)
                        question.answers.insert(answer)
                    }
                    answer.question = question
                    answer.body = value["answer_content"] as? String
                    answer.agreementCount = value["agree_count"] as? NSNumber
                    if answer.user == nil {
                        answer.user = User.cachedObjectWithID(Int(msr_object: value["uid"])!)
                    }
                    let userInfo = value["user_info"] as! NSDictionary
                    answer.user!.name = userInfo["user_name"] as? String
                    answer.user!.avatarURL = userInfo["avatar_file"] as? String
                }
                for value in data["question_topics"] as! [NSDictionary] {
                    let topicID = value["topic_id"] as! NSNumber
                    let topic = Topic.cachedObjectWithID(topicID)
                    topic.title = value["topic_title"] as? String
                    question.topics.insert(topic)
                }
                _ = try? DataManager.defaultManager.saveChanges()
                success?(question)
            },
            failure: failure)
    }
    
    func toggleFocus(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("Focus Question",
            parameters: [
                "question_id": id
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    self_.focusing = (data["type"] as! String == "add")
                    if self_.focusCount != nil {
                        self_.focusCount = self_.focusCount!.integerValue + (self!.focusing! ? 1 : -1)
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func uploadImageWithJPEGData(jpegData: NSData, success: ((Int) -> Void)?, failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation {
        return NetworkManager.defaultManager!.request("Upload Attachment",
            GETParameters: [
                "id": "question",
                "attach_access_key": attachmentKey!],
            POSTParameters: [:],
            constructingBodyWithBlock: {
                data in
                data?.appendPartWithFileData(jpegData, name: "qqfile", fileName: "image.jpg", mimeType: "image/jpeg")
                return
            },
            success: {
                data in
                success?(Int(msr_object: data["attach_id"])!)
                return
            },
            failure: failure)!
    }
    
    func post(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let topics = [Topic](self.topics)
        var topicsParameter = ""
        if topics.count == 1 {
            topicsParameter = topics[0].title!
        } else if topics.count > 1 {
            topicsParameter = topics.map({ $0.title! }).joinWithSeparator(",")
        }
        let title = self.title!
        let body = self.body!
        NetworkManager.defaultManager!.POST("Post Question",
            parameters: [
                "question_content": title,
                "question_detail": body,
                "attach_access_key": attachmentKey!,
                "topics": topicsParameter
            ],
            success: {
                _ in
                success?()
                return
            },
            failure: failure)
    }

}
