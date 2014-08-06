//
//  Topic.swift
//  WeCenterMobile
//
//  Created by Jerry Black on 14-7-30.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

let TopicModel = Model(module: "Topic", bundle: NSBundle.mainBundle())

class Topic: NSManagedObject {
    
    let model = Model(module: "Topic", bundle: NSBundle.mainBundle())

    @NSManaged var allQuestion: NSNumber?
    @NSManaged var beFocus: NSNumber?
    @NSManaged var bestAnswer: NSNumber?
    @NSManaged var bestAnswerer: NSNumber?
    @NSManaged var fatherTopic: NSNumber?
    @NSManaged var followers: NSNumber?
    @NSManaged var index: NSNumber?
    @NSManaged var introduct: String?
    @NSManaged var title: String?
    @NSManaged var topicImageURL: String?
    
    convenience init() {
        let entity = NSEntityDescription.entityForName("Topic",
            inManagedObjectContext: appDelegate.managedObjectContext)
        self.init(entity: entity,
            insertIntoManagedObjectContext: appDelegate.managedObjectContext)
    }
    
    class func parseDictionary(d: NSDictionary) -> Topic {
        let topic = Topic()
        topic.index = (d["topic_id"] as String).toInt()!
        topic.title = d["topic_title"] as? String
        topic.introduct = d["topic_description"] as? String
        topic.topicImageURL = d["topic_pic"] as? String
        return topic
    }
    
    private class func fetchMineTopicListUsingNetwork(user : User, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        TopicModel.GET(TopicModel.URLStrings["Get mine topic list"]!,
            parameters: [
                "uid" : user.id,
                "page" : 1
            ],
            success: {
                property in
                var topics = [Topic]()
                for topicDictionary in property["rsm"]["rows"].asArray() as [NSDictionary] {
                    topics += self.parseDictionary(topicDictionary)
                }
                success?(topics)
            },failure: failure)
    }
    
    private class func fetchMineTopicListUsingCache(user : User, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        var error: NSError? = nil
        let results = appDelegate.managedObjectContext.executeFetchRequest(request, error: &error) as? [[Topic]]
        if error == nil && results!.count != 0 {
            success?(results![0])
        } else {
            failure?(error != nil ? error! : NSError()) // Needs specification
        }
    }
    
    class func fetchMineTopicList(user : User, strategy: Model.Strategy, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchMineTopicListUsingCache(user, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchMineTopicListUsingNetwork(user, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchMineTopicListUsingCache(user, success: success, failure: {
                error in
                self.fetchMineTopicListUsingNetwork(user, success: success, failure: failure)
                })
        case .NetworkFirst:
            fetchMineTopicListUsingNetwork(user, success: success, failure: {
                error in
                self.fetchMineTopicListUsingCache(user, success: success, failure: failure)
                })
        default:
            break
        }
    }
    
    private class func fetchTopicDetailUsingNetwork(user : User, topic : Topic, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        TopicModel.GET(TopicModel.URLStrings["Get topic"]!,
            parameters: [
                "uid" : user.id,
                "topic_id" : topic.index!
            ],
            success: {
                property in
                topic.title = property["rsm"]["topic_title"].asString()
                topic.introduct = property["rsm"]["topic_description"].asString()
                topic.topicImageURL = property["rsm"]["topic_pic"].asString()
                topic.beFocus = property["rsm"]["has_focus"].asBool()
                topic.followers = property["rsm"]["focus_count"].asString().toInt()!
                success?(topic)
            },failure: failure)
    }
    
    private class func fetchTopicDetailUsingCache(user : User, topic : Topic, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        
    }
    
    class func fetchTopicDetail(user : User, topic : Topic, strategy: Model.Strategy, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchTopicDetailUsingCache(user, topic: topic, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchTopicDetailUsingNetwork(user, topic: topic, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchTopicDetailUsingCache(user, topic: topic, success: success, failure: {
                error in
                self.fetchTopicDetailUsingNetwork(user, topic: topic, success: success, failure: failure)
                })
        case .NetworkFirst:
            fetchTopicDetailUsingNetwork(user, topic: topic, success: success, failure: {
                error in
                self.fetchTopicDetailUsingCache(user, topic: topic, success: success, failure: failure)
                })
        default:
            break
        }
    }
    
}
