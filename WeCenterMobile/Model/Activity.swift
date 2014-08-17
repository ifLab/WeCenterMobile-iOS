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
    
    @NSManaged var id: String
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
        let key = property.asDictionary().keys.first!
        let value = Msr.Data.Property(value: property.asDictionary().values.first as NSObject)
        var activity: Activity! = nil
        let userID = value["user_info"]["uid"].asInt()
        let user = Model.autoGenerateManagedObjectByEntityName("User", ID: userID) as User
        user.name = value["user_info"]["user_name"].asString()
        user.avatarURL = User.avatarURLWithURI(value["user_info"]["avatar_file"].asString())
        switch value["post_type"].asString()! {
        case "article":
            activity = Model.createManagedObjecWithEntityName("ArticalActivity") as ArticalActivity
            activity.id = key
            let articalActivity = activity as ArticalActivity
            articalActivity.title = value["title"].asString()
            articalActivity.viewCount = value["views"].asInt()
            articalActivity.commentCount = value["comments"].asInt()
            break
        case "question":
            activity = Model.createManagedObjecWithEntityName("QuestionActivity") as QuestionActivity
            activity.id = key
            let questionActivity = activity as QuestionActivity
            questionActivity.title = value["question_content"]?.asString() ?? ""
            questionActivity.lastUpdatedTime = NSDate(timeIntervalSince1970: NSTimeInterval(value["update_time"]?.asInt() ?? 0))
            questionActivity.answerCount = value["answer_count"]?.asInt() ?? 0
            questionActivity.viewCount = value["view_count"]?.asInt() ?? 0
            questionActivity.focusCount = value["focus_count"]?.asInt() ?? 0
            let answer = value["answer"]
            questionActivity.answerContent = answer["answer_content"].asString()
            if !answer["user_info"].isNull() {
                let info = answer["user_info"]
                questionActivity.answerUser = Model.createManagedObjecWithEntityName("User") as? User
                questionActivity.answerUser!.id = info["uid"].asInt()
                questionActivity.answerUser!.name = info["user_name"].asString()
                if !info["avatar_file"].isNull() {
                    questionActivity.answerUser!.avatarURL = User.avatarURLWithURI(info["avatar_file"].asString())
                }
                questionActivity.answerUserID = questionActivity.answerUser!.id
            }
            if !value["topics"].isNull() {
                questionActivity.topics = []
                for topicInfo in value["topics"].asArray() as [NSDictionary] {
                    let topic = Model.createManagedObjecWithEntityName("Topic") as Topic
                    topic.id = topicInfo["topic_id"] as Int
                    topic.title = topicInfo["topic_title"] as String
                    let relationship = Model.createManagedObjecWithEntityName("QuestionActivity_Topic") as QuestionActivity_Topic
                    relationship.activityID = questionActivity.id
                    relationship.topicID = topic.id
                    questionActivity.topics.append(topic)
                }
            }
            break
        default:
            break
        }
        activity.user = user
        activity.userID = user.id
        activity.addedTime = NSDate(timeIntervalSince1970: NSTimeInterval(value["add_time"]?.asInt() ?? 0))
        appDelegate.saveContext()
        return activity
    }
    
    class func fetchActivityUsingCacheByID(ID: NSNumber, success: ((Activity) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("Activity_By_ID", ID: ID, success: success, failure: failure)
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
                if property["total_rows"].asInt() > 0 {
                    var activityList = [Activity]()
                    for (ID, activityDictionary) in property["rows"].asDictionary() as [String: NSDictionary] {
                        let activity = self.activityWithProperty(Msr.Data.Property(value: [ID: activityDictionary]))
                        activity.id = ID
                        activityList.append(activity)
                    }
                    success?(activityList)
                } else {
                    failure?(NSError(domain: model.URLStrings["Get Activity List"], code: 0, userInfo: ["Hint": "No more data"])) // Needs specification
                }
            },
            failure: failure)
    }

}
