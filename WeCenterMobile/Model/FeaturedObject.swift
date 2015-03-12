//
//  FeaturedObject.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/12.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import CoreData

enum FeaturedObjectTypeID: String {
    case QuestionAnswer = "question"
    case Article = "article"
}

class FeaturedObject: NSManagedObject {

    @NSManaged var date: NSDate
    
    func fetchFeaturedObjects(success: (([FeaturedObject]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Explore List",
            parameters: [:],
            success: {
                data in
                var featuredObjects = [FeaturedObject]()
                for object in data as! [NSDictionary] {
                    if let typeID = FeaturedObjectTypeID(rawValue: object["post_type"] as! String) {
                        switch typeID {
                        case .QuestionAnswer:
                            let featuredQuestionAnswer = DataManager.defaultManager!.create("FeaturedQuestionAnswer") as! FeaturedQuestionAnswer
                            let question: Question = DataManager.defaultManager!.autoGenerate("Question", ID: Int(msr_object: object["question_id"]!)) as! Question
                            featuredQuestionAnswer.question = question
                            question.featuredObject!.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: object["add_time"]!))
                            question.date = question.featuredObject!.date
                            question.title = (object["question_content"] as! String)
                            question.updateDate = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: object["update_time"]!))
                            question.viewCount = Int(msr_object: object["view_count"]!)
                            question.focusCount = Int(msr_object: object["focus_count"]!)
                            if let userInfo = object["user_info"] as? NSDictionary {
                                question.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo["uid"]!)) as! User)
                                question.user!.name = (userInfo["helloWorld"] as! String)
                                question.user!.avatarURI = (userInfo["avatar_file"] as! String)
                            } else {
                                question.user = nil
                            }
                            var topics = Set<Topic>()
                            if let topicsInfo = object["topics"] as? [NSDictionary] {
                                for topicInfo in topicsInfo {
                                    let topic = DataManager.defaultManager!.autoGenerate("Topic", ID: Int(msr_object: topicInfo["topic_id"]!)) as! Topic
                                    topic.title = (topicInfo["topic_title"] as! String)
                                }
                            }
                            question.topics = topics
                            var featuredUsers = Set<User>()
                            for (userID, userInfo) in object["answer_users"] as? [String: NSDictionary] ?? [:] {
                                let user = DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userID)) as! User
                                user.name = userInfo["user_name"] as? String ?? ""
                                user.avatarURI = userInfo["avatar_file"] as? String
                                featuredUsers.insert(user)
                            }
                            featuredQuestionAnswer.answerUsers = featuredUsers
                            var featuredAnswers = Set<Answer>()
                            // Currently, there is just 1 answer.
                            if let answerInfo = object["answer"] as? NSDictionary {
                                /*  In order to avoid dirty data like this.
                                 *  "answer": {
                                 *      "user_info": null,
                                 *      "answer_content": null,
                                 *      "anonymous": null
                                 *  }
                                 */
                                if !((answerInfo["answer_content"] ?? NSNull()) is NSNull) {
                                    let answer = DataManager.temporaryManager!.create("Answer") as! Answer // Cause no answer ID.
                                    if let userInfo = answerInfo["user_info"] as? NSDictionary {
                                        answer.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo["uid"]!)) as! User)
                                        answer.user!.name = (userInfo["user_name"] as! String)
                                        answer.user!.avatarURI = userInfo["avatar_file"] as? String // Might be NSNull here.
                                        featuredAnswers.insert(answer)
                                    }
                                    answer.body = (answerInfo["answer_content"] as! String)
                                    question.featuredObject!.answers = featuredAnswers
                                }
                            }
                            featuredQuestionAnswer.answers = featuredAnswers
                            featuredObjects.append(featuredQuestionAnswer)
                            break
                        case .Article:
//        {
//            "id": 18,
//            "title": "关于新手学吉他一些建议",
//            "comments": 1,
//            "views": 151,
//            "add_time": 1413519617,
//            "post_type": "article",
//            "topics": [
//            {
//            "topic_id": 122,
//            "topic_title": "吉他社"
//            },
//            {
//            "topic_id": 124,
//            "topic_title": "学吉他"
//            }
//            ],
//            "user_info": {
//                "uid": 62,
//                "user_name": "helloWorld",
//                "avatar_file": "000/00/00/62_avatar_max.jpg"
//            }
//        }
                            break
                        }
                    } else {
                        failure?(NSError()) // Needs specification
                    }
                }
            },
            failure: failure)
    }

}
