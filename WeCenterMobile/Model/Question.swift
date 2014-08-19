//
//  Question.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

let QuestionModel = Model(module: "Question", bundle: NSBundle.mainBundle())

class Question: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String?
    @NSManaged var body: String?
    @NSManaged var focusCount: NSNumber?
    
    var focused: Bool? = nil
    
    class func fetchQuestionByID(ID: NSNumber, strategy: Model.Strategy, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchQuestionUsingCacheByID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchQuestionUsingNetworkByID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchQuestionUsingCacheByID(ID, success: success, failure: {
                error in
                self.fetchQuestionUsingNetworkByID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchQuestionUsingNetworkByID(ID, success: success, failure: {
                error in
                self.fetchQuestionUsingCacheByID(ID, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    class func fetchQuestionUsingCacheByID(ID: NSNumber, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("Question_By_ID", ID: ID, success: success, failure: failure)
    }
    
    class func fetchQuestionUsingNetworkByID(ID: NSNumber, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        let question = Model.autoGenerateManagedObjectByEntityName("Question", ID: ID) as Question
        QuestionModel.GET(QuestionModel.URLStrings["GET Detail"]!,
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let value = data["question_info"] as NSDictionary
                question.id = value["question_id"] as NSNumber
                question.title = value["question_content"] as? String
                question.body = value["question_detail"] as? String
                question.focusCount = value["focus_count"] as? NSNumber
                question.focused = (value["has_focus"] as? NSNumber == 1)
                for value in data["answers"] as [NSDictionary] {
                    let answer = Model.autoGenerateManagedObjectByEntityName("Answer", ID: value["answerID"] as NSNumber) as Answer
                    answer.body = value["answer_content"] as? String
                    answer.agreementCount = value["agree_count"] as? NSNumber
                    answer.userID = value["uid"] as? NSNumber
                    let user = Model.autoGenerateManagedObjectByEntityName("User", ID: answer.userID!) as User
                    user.name = value["user_name"] as? String
                    Question_Answer.updateRelationship(questionID: question.id, answerID: answer.id)
                }
                for value in data["question_topics"] as [NSDictionary] {
                    let topic = Model.autoGenerateManagedObjectByEntityName("Topic", ID: value["topic_id"] as NSNumber) as Topic
                    topic.title = value["topic_title"] as? String
                    Question_Topic.updateRelationship(questionID: question.id, topicID: topic.id)
                }
                appDelegate.saveContext()
                success?(question)
            },
            failure: failure)
    }

}
