//
//  Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

let TopicModel = Model(module: "Topic", bundle: NSBundle.mainBundle())

class Topic: NSManagedObject {

    @NSManaged var title: String?
    @NSManaged var id: NSNumber
    @NSManaged var introduction: String?
    @NSManaged var imageURL: String?
    @NSManaged var focusCount: NSNumber?
    
    var focused: Bool? = nil
    
    class func imageURLWithURI(URI: String) -> String {
        return TopicModel.URLStrings["Base"]! + TopicModel.URLStrings["Image Base"]! + URI
    }
    
    class func fetchTopicListByUserID(userID: NSNumber, page: Int, count: Int, strategy: Model.Strategy, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchTopicListUsingCacheByUserID(userID, page: page, count: count, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchTopicListUsingNetworkByUserID(userID, page: page, count: count, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchTopicListUsingCacheByUserID(userID, page: page, count: count, success: success, failure: {
                error in
                self.fetchTopicListUsingNetworkByUserID(userID, page: page, count: count, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchTopicListUsingNetworkByUserID(userID, page: page, count: count, success: success, failure: {
                error in
                self.fetchTopicListUsingCacheByUserID(userID, page: page, count: count, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    private class func fetchTopicListUsingCacheByUserID(userID: NSNumber, page: Int, count: Int, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        User_Topic.fetchRelationshipsUsingCacheByUserID(userID,
            page: page,
            count: count,
            success: {
                relationships in
                var topics = [Topic]()
                for user_topic in relationships {
                    self.fetchTopicByID(user_topic.topicID,
                        strategy: .CacheOnly,
                        success: {
                            topic in
                            topics.append(topic)
                            return
                        },
                        failure: nil)
                }
                success?(topics)
                return
            },
            failure: failure)
    }
    
    private class func fetchTopicListUsingNetworkByUserID(userID: NSNumber, page: Int, count: Int, success: (([Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        TopicModel.GET(TopicModel.URLStrings["GET List"]!,
            parameters: [
                "uid": userID,
                "page": page,
                "per_page": count
            ],
            success: {
                property in
                if property["total_rows"].asInt() > 0 {
                    var topics = [Topic]()
                    for topicDictionary in property["rows"].asArray() as [NSDictionary] {
                        let property = Msr.Data.Property(value: topicDictionary)
                        let topicID = property["topic_id"].asInt()
                        let topic = Model.autoGenerateManagedObjectByEntityName("Topic", ID: topicID) as Topic
                        topic.id = topicID
                        topic.title = property["topic_title"].asString()
                        topic.introduction = property["topic_description"].asString()
                        topic.imageURL = self.imageURLWithURI(property["topic_pic"].asString())
                        topics.append(topic)
                        User_Topic.updateRelationship(userID: userID, topicID: topicID)
                        appDelegate.saveContext()
                    }
                    success?(topics)
                } else {
                    failure?(NSError()) // Needs specification
                }
                return
            },
            failure: failure)
    }
    
    class func fetchTopicByID(ID: NSNumber, strategy: Model.Strategy, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchTopicUsingCacheByID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchTopicUsingNetworkByID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchTopicUsingCacheByID(ID, success: success, failure: {
                error in
                self.fetchTopicUsingNetworkByID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchTopicUsingNetworkByID(ID, success: success, failure: {
                error in
                self.fetchTopicUsingCacheByID(ID, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    private class func fetchTopicUsingCacheByID(ID: NSNumber, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("Topic_By_ID", ID: ID, success: success, failure: failure)
    }
    
    private class func fetchTopicUsingNetworkByID(ID: NSNumber, success: ((Topic) -> Void)?, failure: ((NSError) -> Void)?) {
        let topic = Model.autoGenerateManagedObjectByEntityName("Topic", ID: ID) as Topic
        TopicModel.GET(TopicModel.URLStrings["GET Detail"]!,
            parameters: [
                "uid": appDelegate.currentUser!.id,
                "topic_id": ID
            ],
            success: {
                property in
                topic.title = property["topic_title"].asString()
                topic.introduction = property["topic_description"].asString()
                topic.imageURL = Topic.imageURLWithURI(property["topic_pic"].asString())
                topic.focusCount = property["focus_count"].asInt()
                topic.focused = (property["has_focus"].asInt() == 1)
                appDelegate.saveContext()
                success?(topic)
            },
            failure: failure)
    }
    
    func toggleFocusTopicUsingNetworkByUserID(userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if focused != nil {
            if focused! {
                cancleFocusTopicUsingNetworkByUserID(userID, success: success, failure: failure)
            } else {
                focusTopicUsingNetworkByUserID(userID, success: success, failure: failure)
            }
        } else {
            failure?(NSError()) // Needs specification
        }
    }
    
    func cancleFocusTopicUsingNetworkByUserID(userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        TopicModel.POST(TopicModel.URLStrings["POST Focus"]!,
            parameters: [
                "uid": userID,
                "topic_id": id,
                "type": "cancel"
            ],
            success: {
                property in
                self.focused = false
                success?()
            },
            failure: failure)
    }
    
    func focusTopicUsingNetworkByUserID(userID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        TopicModel.POST(TopicModel.URLStrings["POST Focus"]!,
            parameters: [
                "uid": userID,
                "topic_id": id,
                "type": "focus"
            ],
            success: {
                property in
                self.focused = true
                success?()
            },
            failure: failure)
    }
    
    class func fetchOutstandingQuestionAnswerUserListUsingNetworkByTopicID(topicID: NSNumber,
        success: ([(question: Question, answer: Answer, user: User)] -> Void)?,
        failure: ((NSError) -> Void)?) {
            TopicModel.GET(TopicModel.URLStrings["GET Outstanding"]!,
                parameters: [
                    "id": topicID
                ],
                success: {
                    property in
                    if property["total_rows"].asInt() > 0 {
                        var array: [(question: Question, answer: Answer, user: User)] = []
                        for dictionary in property["rows"].asArray() as [NSDictionary] {
                            let questionValue = Msr.Data.Property(value: dictionary["question_info"] as NSObject)
                            let answerValue = Msr.Data.Property(value: dictionary["answer_info"] as NSObject)
                            let question = Model.autoGenerateManagedObjectByEntityName("Question", ID: questionValue["question_id"].asInt()) as Question
                            question.title = questionValue["question_content"].asString()
                            let answer = Model.autoGenerateManagedObjectByEntityName("Answer", ID: answerValue["answer_id"].asInt()) as Answer
                            answer.body = answerValue["answer_content"].asString()
                            answer.agreementCount = answerValue["agree_count"].asInt()
                            let user = Model.autoGenerateManagedObjectByEntityName("User", ID: answerValue["uid"].asInt()) as User
                            user.avatarURL = User.avatarURLWithURI(answerValue["avatar_file"].asString())
                            array.append((question: question, answer: answer, user: user))
                        }
                        appDelegate.saveContext()
                        success?(array)
                    } else {
                        failure?(NSError()) // Needs specification
                    }
                }, failure: failure)
    }
    
}
