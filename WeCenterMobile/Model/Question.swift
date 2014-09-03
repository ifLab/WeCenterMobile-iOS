//
//  Question.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

let QuestionModel = Model(module: "Question", bundle: NSBundle.mainBundle())

class Question: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String?
    @NSManaged var body: String?
    @NSManaged var focusCount: NSNumber?
    
    var focusing: Bool? = nil
    
    class func fetchQuestionByID(ID: NSNumber, strategy: Model.Strategy, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchQuestionUsingCacheByID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchQuestionUsingNetworkByID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchQuestionUsingCacheByID(ID, success: success, failure: {
                error in
                self.fetchQuestionUsingNetworkByID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchQuestionUsingNetworkByID(ID, success: success, failure: {
                error in
                self.fetchQuestionUsingCacheByID(ID, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    private class func fetchQuestionUsingCacheByID(ID: NSNumber, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("Question_By_ID", ID: ID, success: success, failure: failure)
    }
    
    private class func fetchQuestionUsingNetworkByID(ID: NSNumber, success: ((Question) -> Void)?, failure: ((NSError) -> Void)?) {
        fetchDataForQuestionViewControllerByID(ID,
            strategy: .NetworkOnly,
            success: {
                data in
                success?(data.0)
                return
            },
            failure: failure)
    }
    
    class func fetchDataForQuestionViewControllerByID(ID: NSNumber, strategy: Model.Strategy, success: (((Question, [Topic], [Answer], [User])) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchDataForQuestionViewControllerUsingCacheByID(ID, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchDataForQuestionViewControllerUsingNetworkByID(ID, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchDataForQuestionViewControllerUsingCacheByID(ID, success: success, failure: {
                error in
                self.fetchDataForQuestionViewControllerUsingNetworkByID(ID, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchDataForQuestionViewControllerUsingNetworkByID(ID, success: success, failure: {
                error in
                self.fetchDataForQuestionViewControllerUsingCacheByID(ID, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    private class func fetchDataForQuestionViewControllerUsingCacheByID(ID: NSNumber, success: (((Question, [Topic], [Answer], [User])) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchManagedObjectByTemplateName("Question_By_ID",
            ID: ID,
            success: {
                (question: Question) in
                var topics = [Topic]()
                var answers = [Answer]()
                var users = [User]()
                Question_Topic.fetchRelationshipsUsingCacheByQuestionID(question.id,
                    page: 1,
                    count: Int.max,
                    success: {
                        question_topics in
                        for question_topic in question_topics {
                            Topic.fetchTopicByID(question_topic.topicID,
                                strategy: .CacheOnly,
                                success: {
                                    topic in
                                    topics.append(topic)
                                },
                                failure: failure)
                        }
                    },
                    failure: failure)
                Question_Answer.fetchRelationshipsUsingCacheByQuestionID(question.id,
                    page: 1,
                    count: Int.max,
                    success: {
                        question_answers in
                        for question_answer in question_answers {
                            Answer.fetchAnswerByID(question_answer.answerID,
                                strategy: .CacheOnly,
                                success: {
                                    answer in
                                    answers.append(answer)
                                    User.fetchUserByID(answer.userID!,
                                        strategy: .CacheOnly,
                                        success: {
                                            user in
                                            users.append(user)
                                        }, failure: failure)
                                },
                                failure: failure)
                        }
                    },
                    failure: failure)
                success?((question, topics, answers, users))
            },
            failure: failure)
    }
    
    private class func fetchDataForQuestionViewControllerUsingNetworkByID(ID: NSNumber, success: (((Question, [Topic], [Answer], [User])) -> Void)?, failure: ((NSError) -> Void)?) {
        let question = Model.autoGenerateManagedObjectByEntityName("Question", ID: ID) as Question
        QuestionModel.GET(QuestionModel.URLStrings["GET Detail"]!,
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
                var answers = [Answer]()
                var users = [User]()
                for value in data["answers"] as [NSDictionary] {
                    let answer = Model.autoGenerateManagedObjectByEntityName("Answer", ID: value["answer_id"] as NSNumber) as Answer
                    answer.body = value["answer_content"] as? String
                    answer.agreementCount = value["agree_count"] as? NSNumber
                    answer.userID = value["uid"] as? NSNumber
                    answer.questionID = question.id
                    let user = Model.autoGenerateManagedObjectByEntityName("User", ID: answer.userID!) as User
                    user.name = value["user_name"] as? String
                    let avatarURI = value["avatar_file"] as? String
                    user.avatarURL = (avatarURI == nil) ? nil : User.avatarURLWithURI(avatarURI!)
                    Question_Answer.updateRelationship(questionID: question.id, answerID: answer.id)
                    User_Answer.updateRelationship(userID: user.id, answerID: answer.id)
                    answers.append(answer)
                    users.append(user)
                }
                var topics = [Topic]()
                for value in data["question_topics"] as [NSDictionary] {
                    let topic = Model.autoGenerateManagedObjectByEntityName("Topic", ID: value["topic_id"] as NSNumber) as Topic
                    topic.title = value["topic_title"] as? String
                    Question_Topic.updateRelationship(questionID: question.id, topicID: topic.id)
                    topics.append(topic)
                }
                appDelegate.saveContext()
                success?((question, topics, answers, users))
            },
            failure: failure)
    }
    
    func toggleFocus(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        QuestionModel.GET(QuestionModel.URLStrings["GET Focus"]!,
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
