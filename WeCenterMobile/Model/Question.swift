//
//  Question.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Question: NSManagedObject {

    @NSManaged var body: String?
    @NSManaged var focusCount: NSNumber?
    @NSManaged var id: NSNumber
    @NSManaged var title: String?
    @NSManaged var answers: NSSet
    @NSManaged var questionFocusingActions: NSSet
    @NSManaged var questionPublishmentActions: NSSet
    @NSManaged var topics: NSSet
    @NSManaged var user: User?
    
    var focusing: Bool? = nil
    
    class func get(#ID: NSNumber, error: NSErrorPointer) -> Question? {
        return dataManager.fetch("Question", ID: ID, error: error) as? Question
    }
    
    class func fetch(#ID: NSNumber, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        let question = dataManager.autoGenerate("Question", ID: ID) as Question
        networkManager.GET("Question Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let value = data["question_info"] as NSDictionary
                question.id = value["question_id"] as NSNumber
                question.title = value["question_content"] as? String
                question.body = value["question_detail"] as? String
                question.focusCount = value["focus_count"] as? NSNumber
                question.focusing = (value["has_focus"] as? NSNumber == 1)
                var answerArray = question.answers.allObjects as [Answer]
                for (key, value) in data["answers"] as? [String: NSDictionary] ?? [:] {
                    let answerID = value["answer_id"] as NSNumber
                    var answer: Answer! = answerArray.filter({ $0.id == answerID }).first
                    if answer == nil {
                        answer = dataManager.autoGenerate("Answer", ID: answerID) as Answer
                        answerArray.append(answer)
                    }
                    answer.question = question
                    answer.body = value["answer_content"] as? String
                    answer.agreementCount = value["agree_count"] as? NSNumber
                    if answer.user == nil {
                        answer.user = (dataManager.autoGenerate("User", ID: value["uid"] as NSNumber) as User)
                    }
                    answer.user!.name = value["user_name"] as? String
                    answer.user!.avatarURI = value["avatar_file"] as? String
                }
                question.answers = NSSet(array: answerArray)
                var topicArray = question.topics.allObjects as [Topic]
                for value in data["question_topics"] as [NSDictionary] {
                    let topicID = value["topic_id"] as NSNumber
                    var topic: Topic! = topicArray.filter({ $0.id == topicID }).first
                    if topic == nil {
                        topic = dataManager.autoGenerate("Topic", ID: topicID) as Topic
                        topicArray.append(topic)
                    }
                    topic.title = value["topic_title"] as? String
                }
                success?(question)
            },
            failure: failure)
    }
    
    func toggleFocus(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("Focus Question",
            parameters: [
                "question_id": id
            ],
            success: {
                data in
                self.focusing = (data["type"] as String == "add")
                success?()
            },
            failure: failure)
    }

}
