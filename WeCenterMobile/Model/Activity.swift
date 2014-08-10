//
//  Activity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/2.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

let DiscoveryStrings = Msr.Data.LocalizedStrings(module: "Discovery", bundle: NSBundle.mainBundle())
let DiscoveryModel = Model(module: "Discovery", bundle: NSBundle.mainBundle())

class Activity: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var userID: NSNumber
    @NSManaged var addedTime: NSDate
    @NSManaged var viewCount: NSNumber
    
    var user: User! = nil
    
    enum ListType {
        case New
        case Hot
        case Unanswered
    }
    
    class func activityWithProperty(property: Msr.Data.Property) -> Activity {
        let userModel = Model(module: "User", bundle: NSBundle.mainBundle())
        var activity: Activity! = nil
        let user = Model.createManagedObjectOfClass(User.self, entityName: "User") as User
        user.id = property["user_info"]["uid"].asInt()
        user.name = property["user_info"]["user_name"].asString()
        user.avatarURL = User.avatarURLWithURI(property["user_info"]["avatar_file"].asString())
        switch property["post_type"].asString()! {
        case "article":
            activity = Model.createManagedObjectOfClass(ArticalActivity.self, entityName: "ArticalActivity") as ArticalActivity
            let articalActivity = activity as ArticalActivity
            articalActivity.title = property["title"].asString()
            articalActivity.viewCount = property["views"].asInt()
            articalActivity.commentCount = property["comments"].asInt()
            break
        case "question":
            activity = Model.createManagedObjectOfClass(QuestionActivity.self, entityName: "QuestionActivity") as QuestionActivity
            let questionActivity = activity as QuestionActivity
            questionActivity.title = property["question_content"].asString()
            questionActivity.lastUpdatedTime = NSDate(timeIntervalSince1970: NSTimeInterval(property["update_time"].asInt()))
            questionActivity.answerCount = property["answer_count"].asInt()
            questionActivity.viewCount = property["view_count"].asInt()
            questionActivity.focusCount = property["focus_count"].asInt()
            let answer = property["answer"]
            questionActivity.answerContent = answer["answer_content"].asString()
            if !answer["user_info"].isNull() {
                let info = answer["user_info"]
                questionActivity.answerUser = Model.createManagedObjectOfClass(User.self, entityName: "User") as? User
                questionActivity.answerUser!.id = info["uid"].asInt()
                questionActivity.answerUser!.name = info["user_name"].asString()
                if !info["avatar_file"].isNull() {
                    questionActivity.answerUser!.avatarURL = User.avatarURLWithURI(info["avatar_file"].asString())
                }
                questionActivity.answerUserID = questionActivity.answerUser!.id
            }
            if !property["topics"].isNull() {
                questionActivity.topics = []
                for topicInfo in property["topics"].asArray() as [NSDictionary] {
                    let topic = Model.createManagedObjectOfClass(Topic.self, entityName: "Topic") as Topic
                    topic.index = topicInfo["topic_id"] as Int
                    topic.title = topicInfo["topic_title"] as? String
                    let relationship = Model.createManagedObjectOfClass(QuestionActivity_Topic.self, entityName: "QuestionActivity_Topic") as QuestionActivity_Topic
                    relationship.questionActivityID = questionActivity.id
                    relationship.topicID = topic.index!
                    questionActivity.topics.append(topic)
                }
            }
            break
        default:
            break
        }
        activity.user = user
        activity.userID = user.id
        activity.addedTime = NSDate(timeIntervalSince1970: NSTimeInterval(property["add_time"].asInt()))
        appDelegate.saveContext()
        return activity
    }
    
    class func fetchActivityList(#count: Int, page: Int, dayCount: Int, recommended: Bool, type: ListType, success: (([Activity]) -> Void)?, failure: ((NSError) -> Void)?) {
        let model = Model(module: "Discovery", bundle: NSBundle.mainBundle())
        var sortType = ""
        switch type {
        case .Hot:
            sortType = "hot"
            break
        case .New:
            sortType = "new"
            break
        case .Unanswered:
            sortType = "unresponsive"
            break
        default:
            break
        }
        model.GET(model.URLStrings["Get Activity List"]!,
            parameters: [
                "per_page": count,
                "page": page,
                "day": dayCount,
                "is_recommend": recommended ? 1 : 0,
                "sort_type": sortType
            ],
            success: {
                property in
                var activityList = [Activity]()
                for (key, activityDictionary) in property["rows"].asDictionary() as [String: NSDictionary] {
                    activityList.append(self.activityWithProperty(Msr.Data.Property(value: activityDictionary)))
                }
                success?(activityList)
            },
            failure: failure)
    }

}
