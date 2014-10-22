//
//  Article.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/6.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Article: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var userID: NSNumber?
    @NSManaged var title: String?
    @NSManaged var body: String?
    @NSManaged var agreementCount: NSNumber?
    
    enum Evaluation: Int {
        case None = 0
        case Up = 1
        case Down = -1
    }
    var evaluation: Evaluation? = nil
    
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
    
    lazy var topics: [Topic] = {
        var topics = [Topic]()
        Article_Topic.fetchRelationshipsUsingCacheByArticleID(self.id,
            page: 1,
            count: Int.max,
            success: {
                article_topics in
                for article_topic in article_topics {
                    Topic.fetchTopicByID(article_topic.topicID,
                        strategy: .CacheOnly,
                        success: {
                            topic in
                            topics.append(topic)
                        },
                        failure: nil)
                }
            },
            failure: nil)
        return topics
    }()
    
    class func fetchArticleByID(ID: NSNumber, strategy: Model.Strategy, success: ((Article) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchArticleUsingCacheByID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchArticleUsingNetworkByID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchArticleUsingCacheByID(ID, success: success, failure: {
                error in
                self.fetchArticleUsingNetworkByID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchArticleUsingNetworkByID(ID, success: success, failure: {
                error in
                self.fetchArticleUsingCacheByID(ID, success: success, failure: failure)
            })
            break
        }
    }
    
    class private func fetchArticleUsingNetworkByID(ID: NSNumber, success: ((Article) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.GET("Article Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let articleData = data["article_info"] as NSDictionary
                let article = Model.autoGenerateManagedObjectByEntityName("Article", ID: articleData["id"] as NSNumber) as Article
                article.userID = articleData["uid"] as? NSNumber
                article.title = articleData["title"] as? String
                article.body = articleData["body"] as? String
                article.agreementCount = articleData["votes"] as? NSNumber
                article.evaluation = Evaluation.fromRaw((articleData["vote_value"] as? Int) ?? Evaluation.None.toRaw())
                let user = Model.autoGenerateManagedObjectByEntityName("User", ID: article.userID!) as User
                user.name = articleData["user_name"] as? String
                user.avatarURL = User.avatarURLWithURI(articleData["avatar_file"] as String)
                user.signature = articleData["signature"] as? String
                User_Article.updateRelationship(userID: user.id, articleID: article.id)
                for topicData in data["article_topics"] as [NSDictionary] {
                    let topic = Model.autoGenerateManagedObjectByEntityName("Topic", ID: topicData["topic_id"] as NSNumber) as Topic
                    topic.title = topicData["topic_title"] as? String
                    Article_Topic.updateRelationship(articleID: article.id, topicID: topic.id)
                }
                success?(article)
            },
            failure: failure)
    }
    
    class private func fetchArticleUsingCacheByID(ID: NSNumber, success: ((Article) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("Article_By_ID", ID: ID, success: success, failure: failure)
    }

}
