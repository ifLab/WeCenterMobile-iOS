//
//  Answer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class Answer: DataObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var body: String?
    @NSManaged var commentCount: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber
    @NSManaged var answerActions: Set<AnswerAction>
    @NSManaged var answerAgreementActions: Set<AnswerAgreementAction>
    @NSManaged var comments: Set<AnswerComment>
    @NSManaged var featuredObject: FeaturedQuestionAnswer?
    @NSManaged var question: Question?
    @NSManaged var user: User?
    
    var evaluation: Evaluation? = nil
    
    class func fetch(#ID: NSNumber, success: ((Answer) -> Void)?, failure: ((NSError) -> Void)?) {
        let answer = Answer.cachedObjectWithID(ID)
        NetworkManager.defaultManager!.GET("Answer Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                answer.id = data["answer_id"] as! NSNumber
                answer.body = data["answer_content"] as? String
                answer.date = NSDate(timeIntervalSince1970: NSTimeInterval(data["add_time"] as! NSNumber))
                answer.agreementCount = data["agree_count"] as? NSNumber
                answer.commentCount = data["comment_count"] as? NSNumber
                answer.evaluation = Evaluation(rawValue: Int(msr_object: data["vote_value"]!!) ?? 0)
                answer.user = User.cachedObjectWithID(Int(msr_object: (data as! NSDictionary)["uid"])!)
                answer.user!.name = data["user_name"] as? String
                answer.user!.avatarURI = data["avatar_file"] as? String
                answer.user!.signature = data["signature"] as? String
                success?(answer)
            },
            failure: failure)
    }
    
    func fetchComments(#success: (([AnswerComment]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Answer Comment List",
            parameters: [
                "id": id
            ],
            success: {
                [weak self] data in
                var commentsData = [NSDictionary]()
                if data is [NSDictionary] {
                    commentsData = data as! [NSDictionary]
                }
                var comments = [AnswerComment]()
                for commentData in commentsData {
                    let commentID = Int(msr_object: commentData["id"])!
                    let comment = AnswerComment.cachedObjectWithID(commentID)
                    if commentData["uid"] != nil {
                        let userID = Int(msr_object: commentData["uid"])!
                        comment.user = User.cachedObjectWithID(userID)
                        comment.user!.name = commentData["user_name"] as? String
                    }
                    comment.body = commentData["content"] as? String
                    let timeInterval = commentData["add_time"] as? NSTimeInterval
                    if timeInterval != nil {
                        comment.date = NSDate(timeIntervalSince1970: timeInterval!)
                    }
                    comment.answer = self
                    var atID: NSNumber? = nil
                    if let atIDString = commentData["at_user"]?["uid"] as? String {
                        atID = Int(msr_object: atIDString)
                    }
                    if atID != nil {
                        comment.atUser = User.cachedObjectWithID(atID!)
                        comment.atUser!.name = (commentData["at_user"]?["user_name"] as! String)
                    }
                    self?.comments.insert(comment)
                    comments.append(comment)
                }
                success?(comments)
            },
            failure: failure)
    }
    
    func post(#attachKey: String, success: ((Answer) -> Void)?, failure: ((NSError) -> Void)?) {
        let questionID = question!.id.integerValue
        let body = self.body!
        NetworkManager.defaultManager!.POST("Post Answer",
            parameters: [
                "question_id": questionID,
                "answer_content": body,
                "attach_access_key": attachKey
            ],
            success: {
                [weak self] data in
                let answer = Answer.cachedObjectWithID(Int(msr_object: data["answer_id"])!)
                answer.question = Question.cachedObjectWithID(questionID)
                answer.user = User.currentUser
                answer.body = body
                success?(answer)
                return
            },
            failure: failure)
    }

}
