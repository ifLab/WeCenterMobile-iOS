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
    @NSManaged var userID: NSNumber
    @NSManaged var agreementCount: NSNumber
    @NSManaged var body: String
    @NSManaged var commentCount: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var questionID: NSNumber
    
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
        let update: (Answer) -> Void = {
            answer in
            answer.id = ID
            AnswerModel.GET(AnswerModel.URLStrings["GET Detail"]!,
                parameters: [
                    "id": ID
                ],
                success: {
                    property in
                    answer.id = property["answer_id"].asInt()
                    answer.userID = property["uid"].asInt()
                    answer.questionID = property["question_id"].asInt()
                    answer.body = property["answer_content"].asString()
                    answer.date = NSDate(timeIntervalSince1970: NSTimeInterval(property["add_time"].asInt()))
                    answer.agreementCount = property["agree_count"].asInt()
                    answer.commentCount = property["comment_count"].asInt()
                    answer.evaluation = Evaluation.fromRaw(property["vote_value"].asInt())
                    Question_Answer.updateRelationship(questionID: answer.questionID, answerID: answer.id)
                    var user: User! = nil
                    User.fetchUserByID(answer.userID,
                        strategy: .CacheOnly,
                        success: {
                            _user in
                            user = _user
                        },
                        failure: {
                            error in
                            user = Model.createManagedObjecWithEntityName("User") as User
                            user.id = answer.userID
                        })
                    user.name = property["user_name"].asString()
                    user.avatarURL = User.avatarURLWithURI(property["avatar_file"].asString())
                    user.signature = property["signature"].asString()
                    appDelegate.saveContext()
                    success?(answer)
                },
                failure: failure)
        }
        var answer: Answer! = nil
        fetchAnswerByID(ID,
            strategy: .CacheOnly,
            success: {
                _answer in
                answer = _answer
            },
            failure: {
                error in
                answer = Model.createManagedObjecWithEntityName("Answer") as Answer
            })
        update(answer)
    }

}
