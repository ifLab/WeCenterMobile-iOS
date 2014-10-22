//
//  Activity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/2.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

//let DiscoveryStrings = Msr.Data.LocalizedStrings(module: "Discovery", bundle: NSBundle.mainBundle())
//
//typealias QuestionActivity = (question: Question, response: [(answer: Answer, user: User)])
//typealias ArticleActivity = ()
//
//class Activity {
//    
//    enum ListType {
//        case New
//        case Hot
//        case Unanswered
//    }
//    
//    
//    
//    class func fetchDataForActivityListViewController(#page: Int, count: Int, recommended: Bool, type: ListType, strategy: Model.Strategy, success: (([Any]) -> Void)?, failure: ((NSError) -> Void)?) {
//        
//    }
//    
//    class func fetchDataForActivityListViewControllerUsingCache(#page: Int, count: Int, recommended: Bool, type: ListType, success: (([Any]) -> Void)?, failure: ((NSError) -> Void)?) {
//        
//    }
//    
//    class func fetchDataForActivityListViewControllerUsingNetwork(#page: Int, count: Int, recommended: Bool, type: ListType, success: (([Any]) -> Void)?, failure: ((NSError) -> Void)?) {
//        
//    }
//    
//    class func fetchActivityList(#page: Int, count: Int, recommended: Bool, type: ListType, success: (([Any]) -> Void)?, failure: ((NSError) -> Void)?) {
//        var sortType = ""
//        switch type {
//        case .Hot:
//            sortType = "hot"
//            break
//        case .New:
//            sortType = "new"
//            break
//        case .Unanswered:
//            sortType = "unresponsive"
//            break
//        default:
//            break
//        }
//        DiscoveryModel.GET("Get Activity List",
//            parameters: [
//                "per_page": count,
//                "page": page,
//                "day": 7,
//                "is_recommend": recommended ? 1 : 0,
//                "sort_type": sortType
//            ],
//            success: {
//                data in
//                if data["total_rows"] as NSNumber > 0 {
//                    var activityList = [Activity]()
//                    for (key, value) in data["rows"] as [String: AnyObject] {
//                        var activity: Activity! = nil
//                        let userID = (value["user_info"] as NSDictionary)["uid"] as Int
//                        let user = Model.autoGenerateManagedObjectByEntityName("User", ID: userID) as User
//                        user.name = (value["user_info"] as NSDictionary)["user_name"] as? String
//                        user.avatarURL = User.avatarURLWithURI((value["user_info"] as NSDictionary)["avatar_file"] as String)
//                        switch value["post_type"] as String {
//                        case "article":
//                            activity = Model.createManagedObjecWithEntityName("ArticleActivity") as ArticleActivity
//                            let ArticleActivity = activity as ArticleActivity
//                            ArticleActivity.id = value["id"] as? NSNumber
//                            ArticleActivity.title = value["title"] as? String
//                            ArticleActivity.viewCount = value["views"] as? NSNumber
//                            ArticleActivity.commentCount = value["comments"] as? NSNumber
//                            break
//                        case "question":
//                            activity = Model.createManagedObjecWithEntityName("QuestionActivity") as QuestionActivity
//                            let questionActivity = activity as QuestionActivity
//                            questionActivity.id = value["question_id"] as? NSNumber
//                            questionActivity.title = value["question_content"] as? String
//                            if value["update_time"] != nil && value["update_time"]! != nil { // BACK_END_BUG value["update_time"] might be Optional("nil")
//                                questionActivity.lastUpdatedTime = NSDate(timeIntervalSince1970: NSTimeInterval(value["update_time"] as NSNumber))
//                            }
//                            questionActivity.answerCount = value["answer_count"] as? NSNumber
//                            questionActivity.viewCount = value["view_count"] as? NSNumber
//                            questionActivity.focusCount = value["focus_count"] as? NSNumber
//                            let answer = value["answer"] as NSDictionary
//                            questionActivity.answerContent = answer["answer_content"] as? String
//                            if !(answer["user_info"] is NSNull) {
//                                let info = answer["user_info"] as NSDictionary
//                                questionActivity.answerUser = Model.createManagedObjecWithEntityName("User") as? User
//                                questionActivity.answerUser!.id = info["uid"] as NSNumber
//                                questionActivity.answerUser!.name = info["user_name"] as? String
//                                if !(info["avatar_file"] is NSNull) {
//                                    questionActivity.answerUser!.avatarURL = User.avatarURLWithURI(info["avatar_file"] as String)
//                                }
//                                questionActivity.answerUserID = questionActivity.answerUser!.id
//                            }
//                            if !(value["topics"] is NSNull) {
//                                questionActivity.topics = []
//                                for topicInfo in value["topics"] as [NSDictionary] {
//                                    let topic = Model.createManagedObjecWithEntityName("Topic") as Topic
//                                    topic.id = topicInfo["topic_id"] as NSNumber
//                                    topic.title = topicInfo["topic_title"] as? String
//                                    let relationship = Model.createManagedObjecWithEntityName("QuestionActivity_Topic") as QuestionActivity_Topic
//                                    relationship.activityID = questionActivity.id
//                                    relationship.topicID = topic.id
//                                    questionActivity.topics.append(topic)
//                                }
//                            }
//                            break
//                        default:
//                            break
//                        }
//                        activity.user = user
//                        activity.userID = user.id
//                        activity.addedTime = NSDate(timeIntervalSince1970: NSTimeInterval(value["add_time"]? as? NSNumber ?? 0))
//                        appDelegate.saveContext()
//                        activity.id = key
//                        activityList.append(activity)
//                    }
//                    success?(activityList)
//                } else {
//                    failure?(NSError()) // Needs specification
//                }
//            },
//            failure: failure)
//    }
//}