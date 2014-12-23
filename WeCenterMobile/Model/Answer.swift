//
//  Answer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import CoreData

class Answer: NSManagedObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var body: String?
    @NSManaged var commentCount: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber
    @NSManaged var answerActions: NSSet
    @NSManaged var answerAgreementActions: NSSet
    @NSManaged var comments: NSSet
    @NSManaged var question: Question?
    @NSManaged var user: User?
    
    enum Evaluation: Int {
        case None = 0
        case Up = 1
        case Down = -1
    }
    var evaluation: Evaluation? = nil
    
    class func get(#ID: NSNumber, error: NSErrorPointer) -> Answer? {
        return dataManager.fetch("Answer", ID: ID, error: error) as? Answer
    }
    
    class func fetch(#ID: NSNumber, success: ((Answer) -> Void)?, failure: ((NSError) -> Void)?) {
        let answer = dataManager.autoGenerate("Answer", ID: ID) as Answer
        networkManager.GET("Answer Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                answer.id = data["answer_id"] as NSNumber
                answer.body = data["answer_content"] as? String
                answer.date = NSDate(timeIntervalSince1970: NSTimeInterval(data["add_time"] as NSNumber))
                answer.agreementCount = data["agree_count"] as? NSNumber
                answer.commentCount = data["comment_count"] as? NSNumber
                answer.evaluation = Evaluation(rawValue: (data["vote_value"] as NSNumber).integerValue)
                answer.user = (dataManager.autoGenerate("User", ID: data["uid"] as NSNumber) as User)
                answer.user!.name = data["user_name"] as? String
                answer.user!.avatarURI = data["avatar_file"] as? String
                answer.user!.signature = data["signature"] as? String
                success?(answer)
            },
            failure: failure)
    }
    
    func fetchComments(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("Answer Comment List",
            parameters: [
                "id": id
            ],
            success: {
                data in
                var commentsData = [NSDictionary]()
                if data is [NSDictionary] {
                    commentsData = data as [NSDictionary]
                }
                var array = [AnswerComment]()
                for commentData in commentsData {
                    let commentID = (commentData["id"] as NSString).integerValue
                    let comment = dataManager.autoGenerate("AnswerComment", ID: commentID) as AnswerComment
                    let userID = commentData["uid"] as? NSNumber
                    if userID != nil {
                        comment.user = (dataManager.autoGenerate("User", ID: userID!) as User)
                        comment.user!.name = commentData["user_name"] as? String
                    }
                    comment.body = commentData["content"] as? String
                    let timeInterval = commentData["add_time"] as? NSTimeInterval
                    if timeInterval != nil {
                        comment.date = NSDate(timeIntervalSince1970: timeInterval!)
                    }
                    comment.answer = self
                    let atID = commentData["at_user"]?["uid"] as? NSNumber
                    if atID != nil {
                        comment.atUser = (dataManager.autoGenerate("User", ID: atID!) as User)
                        comment.atUser!.name = commentData["at_user"]?["user_name"] as? NSString as? String // This should be a compiler bug.
                    }
                    array.append(comment)
                }
                self.comments = NSSet(array: array)
                success?()
            },
            failure: failure)
    }

}
