//
//  Question_Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Question_Topic: NSManagedObject {

    @NSManaged var questionID: NSNumber
    @NSManaged var topicID: NSNumber
    
    class func updateRelationship(#questionID: NSNumber, topicID: NSNumber) {
        if !relationshipExists(questionID: questionID, topicID: topicID) {
            let question_topic = Model.createManagedObjecWithEntityName("Question_Topic") as Question_Topic
            question_topic.questionID = questionID
            question_topic.topicID = topicID
            appDelegate.saveContext()
        }
    }
    
    class func fetchRelationshipsUsingCacheByQuestionID(questionID: NSNumber, page: Int, count: Int, success: (([Question_Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("Question_Topic_By_QuestionID", ID: questionID, page: page, count: count, success: success, failure: failure)
    }
    
    class func relationshipExists(#questionID: NSNumber, topicID: NSNumber) -> Bool {
        return Model.relationshipExists("Question_Topic_Check", a: ("QuestionID", questionID), b: ("TopicID", topicID))
    }

}
