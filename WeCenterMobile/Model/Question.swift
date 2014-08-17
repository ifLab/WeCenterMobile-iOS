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
    @NSManaged var title: String
    @NSManaged var body: String
    @NSManaged var focusCount: NSNumber
    
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
                property in
                let value = property["question_info"]
                question.id = value["question_id"].asInt()
                question.title = value["question_content"].asString()
                question.body = value["question_detail"].asString()
                question.focusCount = value["focus_count"].asInt()
                question.focused = (value["has_focus"].asInt() == 1)
                for answerDictionary in property["answers"].asArray() as [NSDictionary] {
                    let value = Msr.Data.Property(value: answerDictionary)
                    let answer = Model.autoGenerateManagedObjectByEntityName("Answer", ID: value["answerID"].asInt()) as Answer
                    answer.body = value["answer_content"].asString()
                    answer.agreementCount = value["agree_count"].asInt()
                    answer.userID = value["uid"].asInt()
                    let user = Model.autoGenerateManagedObjectByEntityName("User", ID: answer.userID) as User
                    user.name = value["user_name"].asString()
                    Question_Answer.updateRelationship(questionID: question.id, answerID: answer.id)
                }
                for topicDictionary in property["question_topics"].asArray() as [NSDictionary] {
                    let value = Msr.Data.Property(value: topicDictionary)
                    let topic = Model.autoGenerateManagedObjectByEntityName("Topic", ID: value["topic_id"].asInt()) as Topic
                    topic.title = value["topic_title"].asString()
                    Question_Topic.updateRelationship(questionID: question.id, topicID: topic.id)
                }
                appDelegate.saveContext()
                success?(question)
            },
            failure: failure)
    }

}
