//
//  Answer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

let AnswerModel = Model(module: "Answer", bundle: NSBundle.mainBundle())

class Answer: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var userID: NSNumber?
    @NSManaged var agreementCount: NSNumber?
    @NSManaged var body: String?
    @NSManaged var commentCount: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var questionID: NSNumber?
    
    enum Evaluation: Int {
        case None = 0
        case Up = 1
        case Down = -1
    }
    var evaluation: Evaluation? = nil
    
    class func fetchAnswerByID(ID: NSNumber, strategy: Model.Strategy, success: ((Answer) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchAnswerUsingCacheByID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchAnswerUsingNetworkByID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchAnswerUsingCacheByID(ID, success: success, failure: {
                error in
                self.fetchAnswerUsingNetworkByID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchAnswerUsingNetworkByID(ID, success: success, failure: {
                error in
                self.fetchAnswerUsingCacheByID(ID, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    class func fetchAnswerUsingCacheByID(ID: NSNumber, success: ((Answer) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("Answer_By_ID", ID: ID, success: success, failure: failure)
    }
    
    class func fetchAnswerUsingNetworkByID(ID: NSNumber, success: ((Answer) -> Void)?, failure: ((NSError) -> Void)?) {
        let answer = Model.autoGenerateManagedObjectByEntityName("Answer", ID: ID) as Answer
        AnswerModel.GET(AnswerModel.URLStrings["GET Detail"]!,
            parameters: [
                "id": ID
            ],
            success: {
                data in
                answer.id = data["answer_id"] as NSNumber
                answer.userID = data["uid"] as? NSNumber
                answer.questionID = data["question_id"] as? NSNumber
                answer.body = data["answer_content"] as? String
                answer.date = NSDate(timeIntervalSince1970: NSTimeInterval(data["add_time"] as NSNumber))
                answer.agreementCount = data["agree_count"] as? NSNumber
                answer.commentCount = data["comment_count"] as? NSNumber
                answer.evaluation = Evaluation.fromRaw(data["vote_value"] as NSNumber)
                Question_Answer.updateRelationship(questionID: answer.questionID!, answerID: answer.id)
                let user = Model.autoGenerateManagedObjectByEntityName("User", ID: answer.userID!) as User
                user.name = data["user_name"] as? String
                user.avatarURL = User.avatarURLWithURI(data["avatar_file"] as String)
                user.signature = data["signature"] as? String
                appDelegate.saveContext()
                success?(answer)
            },
            failure: failure)
    }

}
