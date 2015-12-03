//
//  FeaturedObject.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/12.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

enum FeaturedObjectTypeID: String {
    case QuestionAnswer = "question"
    case Article = "article"
}

enum FeaturedObjectListType: String {
    case New = "new"
    case Hot = "hot"
    case Unsolved = "unresponsive"
    case Recommended = "reommended"
}

class FeaturedObject: DataObject {

    @NSManaged var date: NSDate?
    
    class func fetchFeaturedObjects(page page: Int, count: Int, type: FeaturedObjectListType, success: (([FeaturedObject]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Explore List",
            parameters: [
                "page": page,
                "per_page": count,
                "day": 30,
                "is_recommend": type == .Recommended ? 1 : 0,
                "sort_type": type.rawValue],
            success: {
                data in
                let dataManager = DataManager.temporaryManager! // @TODO: Will move to DataManager.defaultManager in future.
                var featuredObjects = [FeaturedObject]()
                if Int(msr_object: data["total_rows"]!!) <= 0 {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    return
                }
                for object in data["rows"] as! [NSDictionary] {
                    if let typeID = FeaturedObjectTypeID(rawValue: object["post_type"] as! String) {
                        var featuredObject: FeaturedObject!
                        switch typeID {
                        case .QuestionAnswer:
                            let question = dataManager.autoGenerate("Question", ID: Int(msr_object: object["question_id"])!) as! Question
                            let featuredQuestionAnswer = dataManager.autoGenerate("FeaturedQuestionAnswer", ID: question.id) as! FeaturedQuestionAnswer
                            featuredObject = featuredQuestionAnswer
                            featuredQuestionAnswer.question = question
                            featuredQuestionAnswer.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: object["add_time"])!)
                            question.date = featuredQuestionAnswer.date
                            question.title = (object["question_content"] as! String)
//                            question.updatedDate = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: object["update_time"])!)
                            question.viewCount = Int(msr_object: object["view_count"])
//                            question.focusCount = Int(msr_object: object["focus_count"])
                            if let userInfo = object["user_info"] as? NSDictionary {
                                question.user = (dataManager.autoGenerate("User", ID: Int(msr_object: userInfo["uid"])!) as! User)
                                question.user!.name = (userInfo["user_name"] as! String)
                                question.user!.avatarURL = userInfo["avatar_file"] as? String
                            } else {
                                question.user = nil
                            }
                            var topics = Set<Topic>()
                            if let topicsInfo = object["topics"] as? [NSDictionary] {
                                for topicInfo in topicsInfo {
                                    let topic = dataManager.autoGenerate("Topic", ID: Int(msr_object: topicInfo["topic_id"]!)!) as! Topic
                                    topic.title = (topicInfo["topic_title"] as! String)
                                    topics.insert(topic)
                                }
                            }
                            question.topics = topics
                            var featuredUsers = Set<User>()
                            for (userID, userInfo) in object["answer_users"] as? [String: NSDictionary] ?? [:] {
                                let user = dataManager.autoGenerate("User", ID: Int(msr_object: userID)!) as! User
                                user.name = userInfo["user_name"] as? String ?? ""
                                user.avatarURL = userInfo["avatar_file"] as? String
                                featuredUsers.insert(user)
                            }
                            featuredQuestionAnswer.answerUsers = featuredUsers
                            var featuredAnswers = Set<Answer>()
                            // Currently, there is just 1 answer.
                            if let answerInfo = object["answer"] as? NSDictionary {
                                /**
                                 * @TODO: [Bug][Back-End] Dirty data:
                                 * "answer": {
                                 *     "user_info": null,
                                 *     "answer_content": null,
                                 *     "anonymous": null
                                 * }
                                 */
                                if !((answerInfo["answer_content"] ?? NSNull()) is NSNull) {
                                    let answer = Answer.temporaryObject() // Cause no answer ID.
                                    if let userInfo = answerInfo["user_info"] as? NSDictionary {
                                        answer.user = (dataManager.autoGenerate("User", ID: Int(msr_object: userInfo["uid"])!) as! User)
                                        answer.user!.name = (userInfo["user_name"] as! String)
                                        answer.user!.avatarURI = userInfo["avatar_file"] as? String // Might be NSNull or "" here.
                                        featuredAnswers.insert(answer)
                                    } else {
                                        answer.user = nil
                                    }
                                    answer.body = (answerInfo["answer_content"] as! String)
                                    // question.answers.insert(answer) // Bad connections cause no answer ID.
                                }
                            }
                            featuredQuestionAnswer.answers = featuredAnswers
                            break
                        case .Article:
                            let article = dataManager.autoGenerate("Article", ID: Int(msr_object: object["id"])!) as! Article
                            let featuredArticle = dataManager.autoGenerate("FeaturedArticle", ID: article.id) as! FeaturedArticle
                            featuredObject = featuredArticle
                            featuredArticle.article = article
                            featuredArticle.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: object["add_time"])!)
                            article.title = (object["title"] as! String)
                            article.date = featuredArticle.date
                            article.viewCount = Int(msr_object: object["views"])
                            var topics = Set<Topic>()
                            if let topicsInfo = object["topics"] as? [NSDictionary] {
                                for topicInfo in topicsInfo {
                                    let topic = dataManager.autoGenerate("Topic", ID: Int(msr_object: topicInfo["topic_id"])!) as! Topic
                                    topic.title = (topicInfo["topic_title"] as! String)
                                    topics.insert(topic)
                                }
                            }
                            if let userInfo = object["user_info"] as? NSDictionary {
                                let user = dataManager.autoGenerate("User", ID: Int(msr_object: userInfo["uid"])!) as! User
                                user.name = (userInfo["user_name"] as! String)
                                user.avatarURL = userInfo["avatar_file"] as? String
                                article.user = user
                            } else {
                                article.user = nil
                            }
                            break
                        }
                        featuredObjects.append(featuredObject)
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                        return
                    }
                }
                _ = try? DataManager.defaultManager.saveChanges()
                success?(featuredObjects)
            },
            failure: failure)
    }

}
