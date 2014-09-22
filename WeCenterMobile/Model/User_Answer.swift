//
//  User_Answer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class User_Answer: NSManagedObject {

    @NSManaged var userID: NSNumber
    @NSManaged var answerID: NSNumber
    
    class func updateRelationship(#userID: NSNumber, answerID: NSNumber) {
        if !relationshipExists(userID: userID, answerID: answerID) {
            let user_answer = Model.createManagedObjecWithEntityName("User_Answer") as User_Answer
            user_answer.userID = userID
            user_answer.answerID = answerID
            appDelegate.saveContext()
        }
    }
    
    class func fetchRelationshipsUsingCacheByUserID(userID: NSNumber, page: Int, count: Int, success: (([User_Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("User_Answer_By_UserID", ID: userID, page: page, count: count, success: success, failure: failure)
    }
    
    class func relationshipExists(#userID: NSNumber, answerID: NSNumber) -> Bool {
        return Model.relationshipExists("User_Answer_Check", a: ("UserID", userID), b: ("AnswerID", answerID))
    }

}
