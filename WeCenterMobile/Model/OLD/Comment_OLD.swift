//
//  Comment.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/9/22.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Comment: NSManagedObject {
    
    @NSManaged var id: NSNumber?
    @NSManaged var userID: NSNumber?
    @NSManaged var body: String
    @NSManaged var date: NSDate
    @NSManaged var atID: NSNumber?
    @NSManaged var answerID: NSNumber
    
    lazy var atUser: User? = {
        var user: User? = nil
        if self.atID != nil {
            User.fetchUserByID(self.atID!,
                strategy: .CacheOnly,
                success: {
                    _user in
                    user = _user
                },
                failure: nil)
        }
        return user
    }()
    
    lazy var user: User? = {
        var user: User? = nil
        if self.userID != nil {
            User.fetchUserByID(self.userID!,
                strategy: .CacheOnly,
                success: {
                    _user in
                    user = _user
                },
                failure: nil)
        }
        return user
    }()
    
    class func fetchCommentListByAnswerID(ID: NSNumber, strategy: Model.Strategy, success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchCommentListUsingCacheByAnswerID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchCommentListUsingNetworkByAnswerID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchCommentListUsingCacheByAnswerID(ID, success: success, failure: {
                error in
                self.fetchCommentListUsingNetworkByAnswerID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchCommentListUsingNetworkByAnswerID(ID, success: success, failure: {
                error in
                self.fetchCommentListUsingCacheByAnswerID(ID, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    private class func fetchCommentListUsingCacheByAnswerID(ID: NSNumber, success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("Answer_Comment_By_AnswerID",
            ID: ID,
            page: 1,
            count: Int.max,
            sortBy: nil,
            success: {
                (answer_comments: [Answer_Comment]) in
                var comments = [Comment]()
                for answer_comment in answer_comments {
                    let commentID = answer_comment.commentID
                    Model.fetchManagedObjectByTemplateName("Comment_By_ID",
                        ID: ID,
                        success: {
                            (comment: Comment) in
                            comments.append(comment)
                        },
                        failure: failure)
                }
                success?(comments)
            },
            failure: failure)
    }
    
    private class func fetchCommentListUsingNetworkByAnswerID(ID: NSNumber, success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.GET("Answer Comment List",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                var commentsData = [NSDictionary]()
                if data is NSDictionary {
                    commentsData = [data as NSDictionary]
                } else {
                    commentsData = data as [NSDictionary]
                }
                var comments = [Comment]()
                for commentData in commentsData {
                    let comment = Model.autoGenerateManagedObjectByEntityName("Comment", ID: commentData["id"] as? NSNumber ?? -1) as Comment
                    comment.userID = commentData["uid"] as? NSNumber
                    comment.body = commentData["body"] as String
                    comment.date = NSDate(timeIntervalSince1970: commentData["add_time"] as NSTimeInterval)
                    comment.answerID = ID
                    comment.atID = commentData["at_user"]?["uid"] as? NSNumber
                    let user = Model.autoGenerateManagedObjectByEntityName("User", ID: comment.userID!) as User
                    user.name = commentData["user_name"] as? String
                    User_Comment.updateRelationship(userID: user.id, commentID: comment.id!)
                    if comment.atID != nil {
                        let atUser = Model.autoGenerateManagedObjectByEntityName("User", ID: comment.atID!) as User
                        atUser.name = commentData["at_user"]?["user_name"] as? NSString as? String // This should be a compiler bug.
                    }
                    comments.append(comment)
                }
                success?(comments)
            },
            failure: failure)
    }

}
