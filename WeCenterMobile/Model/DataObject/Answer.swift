//
//  Answer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import AFNetworking
import CoreData
import Foundation

class Answer: DataObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var attachmentKey: String?
    @NSManaged var body: String?
    @NSManaged var commentCount: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var answerActions: Set<AnswerAction>
    @NSManaged var answerAgreementActions: Set<AnswerAgreementAction>
    @NSManaged var comments: Set<AnswerComment>
    @NSManaged var featuredObject: FeaturedQuestionAnswer?
    @NSManaged var question: Question?
    @NSManaged var user: User?
    
    var title: String? {
        set {
            question?.title = newValue
        }
        get {
            return question?.title
        }
    }
    
    var evaluation: Evaluation? = nil
    
    class func fetch(ID ID: NSNumber, success: ((Answer) -> Void)?, failure: ((NSError) -> Void)?) {
        let answer = Answer.cachedObjectWithID(ID)
        NetworkManager.defaultManager!.GET("Answer Detail",
            parameters: [
                "answer_id": ID
            ],
            success: {
                data in
                let answerData = data["answer"] as! NSDictionary
                answer.id = answerData["answer_id"] as! NSNumber
                answer.body = answerData["answer_content"] as? String
                answer.date = NSDate(timeIntervalSince1970: NSTimeInterval(answerData["add_time"] as! NSNumber))
                answer.agreementCount = answerData["agree_count"] as? NSNumber
                answer.commentCount = answerData["comment_count"] as? NSNumber
                answer.evaluation = Evaluation(rawValue: Int(msr_object: answerData["user_vote_status"]!) ?? 0)
                let userInfo = answerData["user_info"] as! NSDictionary
                answer.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                answer.user!.name = userInfo["user_name"] as? String
                answer.user!.avatarURL = userInfo["avatar_file"] as? String
                answer.user!.signature = userInfo["signature"] as? String
                _ = try? DataManager.defaultManager.saveChanges()
                success?(answer)
            },
            failure: failure)
    }
    
    func fetchComments(success success: (([AnswerComment]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Answer Comment List",
            parameters: [
                "answer_id": id
            ],
            success: {
                [weak self] data in
                if let self_ = self {
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
                            let userInfo = commentData["user_info"] as! NSDictionary
                            comment.user!.name = userInfo["user_name"] as? String
                        }
                        comment.body = commentData["message"] as? String
                        let timeInterval = commentData["time"] as? NSTimeInterval
                        if timeInterval != nil {
                            comment.date = NSDate(timeIntervalSince1970: timeInterval!)
                        }
                        comment.answer = self_
                        /// @TODO: [Bug][Back-End] commentData["at_user"] shouldn't be a nested dictionary.
                        let atUserData = (commentData["at_user"] as? [NSObject: [String: AnyObject]])?.values.first
                        if let atID = Int(msr_object: atUserData?["uid"]) {
                            comment.atUser = User.cachedObjectWithID(atID)
                            comment.atUser!.name = (atUserData?["user_name"] as! String)
                        }
                        self_.comments.insert(comment)
                        comments.append(comment)
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?(comments)
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func uploadImageWithJPEGData(jpegData: NSData, success: ((Int) -> Void)?, failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation {
        return NetworkManager.defaultManager!.request("Upload Attachment",
            GETParameters: [
                "id": "answer",
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
    
    /// @TODO: [Feature][Back-End] Add 'agreementCount' & 'evaluation' in return value.
    /// @TODO: [Feature] Better Evaluation.None parameter support.
    func evaluate(value value: Evaluation, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let originalValue = evaluation
        if originalValue == nil {
            let userInfo = [
                NSLocalizedDescriptionKey: "Couldn't evaluate answer now.",
                NSLocalizedFailureReasonErrorKey: "Current user evaluation data equals to nil. (answer.evaluation == nil)"
            ]
            let error = NSError(
                domain: NetworkManager.defaultManager!.website,
                code: NetworkManager.defaultManager!.internalErrorCode.integerValue,
                userInfo: userInfo)
            failure?(error)
        }
        if value == originalValue {
            success?()
            return
        }
        NetworkManager.defaultManager!.POST("Evaluate Answer",
            parameters: [
                "answer_id": id,
                "value": value == .None ? originalValue!.rawValue : value.rawValue],
            success: {
                [weak self] data in
                if let self_ = self {
                    self_.evaluation = value
                    if let count = self_.agreementCount?.integerValue {
                        /// @TODO: [Feature][Back-End] This property should be provided by back-end.
                        self_.agreementCount = originalValue == .Up ? count - 1 : value == .Up ? count + 1 : count
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func post(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let questionID = question!.id.integerValue
        let body = self.body!
        NetworkManager.defaultManager!.POST("Post Answer",
            parameters: [
                "question_id": questionID,
                "answer_content": body,
                "attach_access_key": attachmentKey!
            ],
            success: {
                _ in
                success?()
                return
            },
            failure: failure)
    }

}
