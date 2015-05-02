//
//  Article.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class Article: NSManagedObject {

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
    
    enum Evaluation: Int {
        case None = 0
        case Up = 1
        case Down = -1
    }
    var evaluation: Evaluation? = nil
    
    class func fetch(#ID: NSNumber, success: ((Article) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Article Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let article = DataManager.defaultManager!.autoGenerate("Article", ID: ID) as! Article
                let info = data["article_info"] as! NSDictionary
                article.id = Int(msr_object: info["id"])!
                if let userID = Int(msr_object: info["uid"]) {
                    article.user = (DataManager.defaultManager!.autoGenerate("User", ID: userID) as! User)
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
                        let topic = DataManager.defaultManager!.autoGenerate("Topic", ID: topicID) as! Topic
                        topic.title = (topicInfo["topic_title"] as! String)
                        article.topics.insert(topic)
                    }
                }
                success?(article)
            },
            failure: failure)
    }

}
