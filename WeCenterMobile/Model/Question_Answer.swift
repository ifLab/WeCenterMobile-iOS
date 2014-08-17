//
//  Question_Answer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Question_Answer: NSManagedObject {

    @NSManaged var questionID: NSNumber
    @NSManaged var answerID: NSNumber
    
    class func updateRelationship(#questionID: NSNumber, answerID: NSNumber) {
        if !relationshipExists(questionID: questionID, answerID: answerID) {
            let question_answer = Model.createManagedObjecWithEntityName("Question_Answer") as Question_Answer
            question_answer.questionID = questionID
            question_answer.answerID = answerID
            appDelegate.saveContext()
        }
    }
    
    class func fetchRelationshipsUsingCacheByQuestionID(questionID: NSNumber, page: Int, count: Int, success: (([User_Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("Question_Answer_By_QuestionID", ID: questionID, page: page, count: count, success: success, failure: failure)
    }
    
    class func relationshipExists(#questionID: NSNumber, answerID: NSNumber) -> Bool {
        return Model.relationshipExists("Question_Answer_Check", a: ("QuestionID", questionID), b: ("AnswerID", answerID))
    }

}
