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
                data in
                if (data["total_rows"] as NSString).integerValue > 0 {
                    var topics = [Topic]()
                    for value in data["rows"] as [NSDictionary] {
                        let topicID = (value["topic_id"] as NSString).integerValue
                        let topic = Model.autoGenerateManagedObjectByEntityName("Topic", ID: topicID) as Topic
                        topic.id = topicID
                        topic.title = value["topic_title"] as? String
                        topic.introduction = value["topic_description"] as? String
                        topic.imageURL = self.imageURLWithURI(value["topic_pic"] as String)
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
                data in
                topic.title = data["topic_title"] as? String
                topic.introduction = data["topic_description"] as? String
                topic.imageURL = Topic.imageURLWithURI(data["topic_pic"] as String)
                topic.focusCount = data["focus_count"] as? NSNumber
                topic.focused = (data["has_focus"] as? NSNumber == 1)
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
                data in
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
                data in
                self.focused = true
                success?()
            },
            failure: failure)
    }
    
    class func fetchTopicOutstandingQuestionAnswerListUsingNetworkByTopicID(topicID: NSNumber,
        success: ([(question: Question, answer: Answer, user: User)] -> Void)?,
        failure: ((NSError) -> Void)?) {
            TopicModel.GET(TopicModel.URLStrings["GET Outstanding"]!,
                parameters: [
                    "id": topicID
                ],
                success: {
                    data in
                    if data["total_rows"] as NSNumber > 0 {
                        var array: [(question: Question, answer: Answer, user: User)] = []
                        for value in data["rows"] as [NSDictionary] {
                            let questionValue = value["question_info"] as NSDictionary
                            let answerValue = value["answer_info"] as NSDictionary
                            let question = Model.autoGenerateManagedObjectByEntityName("Question", ID: questionValue["question_id"] as NSNumber) as Question
                            question.title = questionValue["question_content"] as? String
                            let answer = Model.autoGenerateManagedObjectByEntityName("Answer", ID: answerValue["answer_id"] as NSNumber) as Answer
                            answer.body = answerValue["answer_content"] as? String
                            answer.agreementCount = answerValue["agree_count"] as? NSNumber
                            let user = Model.autoGenerateManagedObjectByEntityName("User", ID: answerValue["uid"] as NSNumber) as User
                            user.avatarURL = User.avatarURLWithURI(answerValue["avatar_file"] as String)
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
