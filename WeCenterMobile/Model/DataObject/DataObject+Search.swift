//
//  Search.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/15.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation

extension DataObject {
    
    class func fetchSearchResultsWithKeyword(keyword: String, type: SearchType, page: Int, success: (([DataObject]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Search",
            parameters: [
                "search_type": type.rawValue,
                "q": keyword,
                "page": page
            ],
            success: {
                data in
                var objects = [DataObject]()
                for objectData in data["rows"] as? [NSDictionary] ?? [] {
                    if let typeRawValue = objectData["type"] as? String {
                        switch SearchType(rawValue: typeRawValue) {
                        case .Some(.Article):
                            /// @TODO: [Feature][Back-End] Add 'user_name' & 'user_avatar' in return value.
                            let articleID = Int(msr_object: objectData["search_id"])!
                            let article = Article.cachedObjectWithID(articleID)
                            if !((objectData["uid"] ?? NSNull()) is NSNull) {
                                let userID = Int(msr_object: objectData["uid"])!
                                article.user = User.cachedObjectWithID(userID)
                            }
                            article.title = (objectData["name"] as! String)
                            if let detailData = objectData["detail"] as? NSDictionary {
                                // article.commentCount = Int(msr_object: detailData["comments"])!
                                /// @TODO: [Feature] Add 'commentCount' property to Article object.
                                article.viewCount = Int(msr_object: detailData["views"])!
                            }
                            objects.append(article)
                            break
                        case .Some(.Question):
                            let questionID = Int(msr_object: objectData["search_id"])!
                            let question = Question.cachedObjectWithID(questionID)
                            if !((objectData["uid"] ?? NSNull()) is NSNull) {
                                let userID = Int(msr_object: objectData["uid"])!
                                question.user = User.cachedObjectWithID(userID)
                            }
                            question.title = (objectData["name"] as! String)
                            if let detailData = objectData["detail"] as? NSDictionary {
                                // question.answerCount = Int(msr_object: detailData["answer_count"])!
                                /// @TODO: [Feature] Add 'answerCount' property to Question object.
                                question.focusCount = Int(msr_object: detailData["focus_count"])!
                            }
                            if let focusData = objectData["focus"] as? NSNumber {
                                question.focusing = focusData.boolValue
                            }
                            objects.append(question)
                            break
                        case .Some(.Topic):
                            let topicID = Int(msr_object: objectData["search_id"])!
                            let topic = Topic.cachedObjectWithID(topicID)
                            topic.title = (objectData["name"] as! String)
                            if let detailData = objectData["detail"] as? NSDictionary {
                                topic.imageURL = (detailData["topic_pic"] as! String)
                                topic.focusCount = Int(msr_object: detailData["focus_count"])!
                                topic.introduction = (detailData["topic_description"] as! String)
                            }
                            objects.append(topic)
                            break
                        case .Some(.User):
                            let userID = Int(msr_object: objectData["search_id"])!
                            let user = User.cachedObjectWithID(userID)
                            user.name = (objectData["name"] as! String)
                            if let detailData = objectData["detail"] as? NSDictionary {
                                user.avatarURL = (detailData["avatar_file"] as! String)
                                user.signature = detailData["signature"] as? String // Might be NSNull
                                user.agreementCount = Int(msr_object: detailData["agree_count"])!
                                user.thankCount = Int(msr_object: detailData["thanks_count"])!
                            }
                            if let followingData = objectData["focus"] as? NSNumber {
                                user.following = followingData.boolValue
                            }
                            objects.append(user)
                            break
                        default:
                            break
                        }
                    }
                }
                _ = try? DataManager.defaultManager.saveChanges()
                success?(objects)
            },
            failure: failure)
    }
    
}
