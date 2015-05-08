//
//  Article.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class Article: DataObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var body: String?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber
    @NSManaged var title: String?
    @NSManaged var viewCount: NSNumber?
    @NSManaged var articleAgreementActions: Set<ArticleAgreementAction>
    @NSManaged var articlePublishmentActions: Set<ArticlePublishmentAction>
    @NSManaged var featuredObject: FeaturedArticle
    @NSManaged var topics: Set<Topic>
    @NSManaged var user: User?
    @NSManaged var comments: Set<ArticleComment>

    var evaluation: Evaluation? = nil
    
    class func fetch(#ID: NSNumber, success: ((Article) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Article Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let article = Article.cachedObjectWithID(ID)
                let info = data["article_info"] as! NSDictionary
                article.id = Int(msr_object: info["id"])!
                if let userID = Int(msr_object: info["uid"]) {
                    article.user = User.cachedObjectWithID(userID)
                    article.user!.name = (info["user_name"] as! String)
                    article.user!.signature = info["signature"] as? String
                    article.user!.avatarURI = info["avatar_file"] as? String
                }
                article.title = (info["title"] as! String)
                article.body = (info["message"] as! String)
                article.agreementCount = Int(msr_object: info["votes"])
                article.evaluation = Evaluation(rawValue: Int(msr_object: info["vote_value"])!)
                article.topics = Set()
                if let topicsInfo = data["article_topics"] as? [NSDictionary] {
                    for topicInfo in topicsInfo {
                        let topicID = Int(msr_object: topicInfo["topic_id"])!
                        let topic = Topic.cachedObjectWithID(topicID)
                        topic.title = (topicInfo["topic_title"] as! String)
                        article.topics.insert(topic)
                    }
                }
                success?(article)
            },
            failure: failure)
    }
    
    func fetchComments(#success: (([ArticleComment]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Article Comment List",
            parameters: [
                "id": id
            ],
            success: {
                [weak self] data in
                if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                    let commentsData = data["rows"] as! [NSDictionary]
                    var comments = [ArticleComment]()
                    self?.comments = Set()
                    for info in commentsData {
                        let comment = ArticleComment.cachedObjectWithID(Int(msr_object: info["id"])!)
                        comment.body = (info["message"] as! String)
                        comment.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: info["add_time"])!)
                        comment.agreementCount = Int(msr_object: info["votes"])
                        comment.evaluation = Evaluation(rawValue: Int(msr_object: info["vote_value"])!)
                        if let userInfo = info["user_info"] as? NSDictionary {
                            comment.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                            comment.user!.name = (userInfo["user_name"] as! String)
                            comment.user!.avatarURI = userInfo["avatar_file"] as? String
                        }
                        if let atUserInfo = info["at_user_info"] as? NSDictionary {
                            comment.atUser = User.cachedObjectWithID(Int(msr_object: atUserInfo["uid"])!)
                            comment.atUser!.name = (atUserInfo["user_name"] as! String)
                            comment.atUser!.avatarURI = atUserInfo["avatar_file"] as? String
                        }
                        comments.append(comment)
                        self?.comments.insert(comment)
                    }
                    success?(comments)
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
}
