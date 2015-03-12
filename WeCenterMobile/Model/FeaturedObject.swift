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
                for object in data as! [NSDictionary] {
                    if let typeID = FeaturedObjectTypeID(rawValue: object["post_type"] as! String){
                        switch typeID {
                        case .QuestionAnswer:
                            let question: Question = DataManager.defaultManager!.autoGenerate("Question", ID: Int(msr_object: object["question_id"]!)) as! Question
                            if question.featuredObject == nil {
                                question.featuredObject = (DataManager.defaultManager!.create("FeaturedQuestionAnswer") as! FeaturedQuestionAnswer)
                            }
                            question.featuredObject!.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: object["add_time"]!))
                            question.viewCount = Int(msr_object: object["view_count"]!)
                            question.focusCount = Int(msr_object: object["focus_count"]!)
                            if let userInfo = object["user_info"] as? NSDictionary {
                                question.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: userInfo["uid"]!)) as! User)
                                question.user!.name = (userInfo["helloWorld"] as! String)
                                question.user!.avatarURI = (userInfo["avatar_file"] as! String)
                            } else {
                                question.user = nil
                            }
                            let featuredAnswers = Set<Answer>()
                            // Currently, there is just 1 answer.
                            if let answer = object["answer"] as? NSDictionary {
                                /*  In order to avoid dirty data like this.
                                 *  "answer": {
                                 *      "user_info": null,
                                 *      "answer_content": null,
                                 *      "anonymous": null
                                 *  }
                                 */
                                if !((answer["answer_content"] ?? NSNull()) is NSNull) {
//                                    question.answers.setByAddingObjectsFromSet(NSObject() as! Set<NSObject>)
                                }
                            }
                            question.featuredObject!.answers = featuredAnswers
                            break
                        case .Article:
                            break
                        }
                    } else {
                        failure?(NSError()) // Needs specification
                    }
                }
            },
            failure: failure)
//        {
//            "question_id": 115,
//            "question_content": "机械设计及自动化考研该怎么复习？",
//            "add_time": 1416929660,
//            "update_time": 1421653309,
//            "published_uid": 59,
//            "answer_count": 3,
//            "answer_users": {
//                "78": {
//                    "uid": 78,
//                    "user_name": "onlyone",
//                    "avatar_file": ""
//                },
//                "84": {
//                    "uid": 84,
//                    "user_name": "jacksunblack",
//                    "avatar_file": ""
//                }
//            },
//            "view_count": 72,
//            "focus_count": 4,
//            "answer": {
//                "user_info": {
//                    "uid": 84,
//                    "user_name": "jacksunblack",
//                    "avatar_file": null
//                },
//                "answer_content": "[attach]197[/attach]",
//                "anonymous": 0
//            },
//            "post_type": "question",
//            "topics": [
//            {
//            "topic_id": 130,
//            "topic_title": "考研"
//            }
//            ],
//            "user_info": {
//                "uid": 59,
//                "user_name": "timor",
//                "avatar_file": "000/00/00/59_avatar_max.jpg"
//            }
//        }
        
        
        
//            {
//                "question_id": 112,
//                "question_content": "求自动化考试题",
//                "add_time": 1416904347,
//                "update_time": 1416904347,
//                "published_uid": 59,
//                "answer_count": 0,
//                "answer_users": 0,
//                "view_count": 61,
//                "focus_count": 2,
//                "answer": {
//                    "user_info": null,
//                    "answer_content": null,
//                    "anonymous": null
//                },
//                "post_type": "question",
//                "topics": [
//                {
//                "topic_id": 128,
//                "topic_title": "考试题"
//                }
//                ],
//                "user_info": {
//                    "uid": 59,
//                    "user_name": "timor",
//                    "avatar_file": "000/00/00/59_avatar_max.jpg"
//                }
//        }
        
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
    }

}
