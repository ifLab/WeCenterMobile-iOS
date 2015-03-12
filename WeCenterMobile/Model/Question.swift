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
    @NSManaged var date: NSDate?
    @NSManaged var viewCount: NSNumber?
    @NSManaged var focusCount: NSNumber?
    @NSManaged var id: NSNumber
    @NSManaged var title: String?
    @NSManaged var updateDate: NSDate?
    @NSManaged var answers: Set<Answer>
    @NSManaged var featuredObject: FeaturedQuestionAnswer?
    @NSManaged var questionFocusingActions: Set<QuestionFocusingAction>
    @NSManaged var questionPublishmentActions: Set<QuestionPublishmentAction>
    @NSManaged var topics: Set<Topic>
    @NSManaged var user: User?
    
    var focusing: Bool? = nil
    
    class func get(#ID: NSNumber, error: NSErrorPointer) -> Question? {
        return DataManager.defaultManager!.fetch("Question", ID: ID, error: error) as? Question
    }
    
    class func fetch(#ID: NSNumber, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        let question = DataManager.defaultManager!.autoGenerate("Question", ID: ID) as! Question
        NetworkManager.defaultManager!.GET("Question Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let value = data["question_info"] as! NSDictionary
                question.id = value["question_id"] as! NSNumber
                question.title = value["question_content"] as? String
                question.body = value["question_detail"] as? String
                question.focusCount = value["focus_count"] as? NSNumber
                question.focusing = (value["has_focus"] as? NSNumber == 1)
                for (key, value) in data["answers"] as? [String: NSDictionary] ?? [:] {
                    let answerID = value["answer_id"] as! NSNumber
                    var answer: Answer! = filter(question.answers) { $0.id == answerID }.first
                    if answer == nil {
                        answer = DataManager.defaultManager!.autoGenerate("Answer", ID: answerID) as! Answer
                        question.answers.insert(answer)
                    }
                    answer.question = question
                    answer.body = value["answer_content"] as? String
                    answer.agreementCount = value["agree_count"] as? NSNumber
                    if answer.user == nil {
                        answer.user = (DataManager.defaultManager!.autoGenerate("User", ID: Int(msr_object: value["uid"]!)) as! User)
                    }
                    answer.user!.name = value["user_name"] as? String
                    answer.user!.avatarURI = value["avatar_file"] as? String
                }
                for value in data["question_topics"] as! [NSDictionary] {
                    let topicID = value["topic_id"] as! NSNumber
                    let topic = DataManager.defaultManager!.autoGenerate("Topic", ID: topicID) as! Topic
                    topic.title = value["topic_title"] as? String
                    question.topics.insert(topic)
                }
                success?(question)
            },
            failure: failure)
    }
    
    func toggleFocus(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Focus Question",
            parameters: [
                "question_id": id
            ],
            success: {
                data in
                self.focusing = (data["type"] as! String == "add")
                success?()
            },
            failure: failure)
    }

}
