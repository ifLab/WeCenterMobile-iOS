//
//  Question.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Question: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String?
    @NSManaged var body: String?
    @NSManaged var focusCount: NSNumber?
    @NSManaged var user: User?
    
    var focusing: Bool? = nil
    
    lazy var answers: [Answer] = {
        var answers = [Answer]()
        Question_Answer.fetchRelationshipsUsingCacheByQuestionID(self.id,
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
                        },
                        failure: nil)
                }
            },
            failure: nil)
        return answers
    }()
    
    lazy var topics: [Topic] = {
        var topics = [Topic]()
        Question_Topic.fetchRelationshipsUsingCacheByQuestionID(self.id,
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
                        failure: nil)
                }
            },
            failure: nil)
        return topics
    }()
    
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
        let question = Model.autoGenerateManagedObjectByEntityName("Question", ID: ID) as Question
        Model.GET("Question Detail",
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
                for (key, value) in data["answers"] as [String: NSDictionary] {
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
                success?(question)
            },
            failure: failure)
    }
    
    class func fetchUserQuestionListByUserID(userID: NSNumber, page: Int, count: Int, strategy: Model.Strategy, success: (([Question]) -> Void)?, failure: ((NSError) -> Void)?) {
        switch strategy {
        case .CacheOnly:
            fetchUserQuestionListUsingCacheByUserID(userID, page: page, count: count, success: success, failure: failure)
            break
        case .NetworkOnly:
            fetchUserQuestionListUsingNetworkByUserID(userID, page: page, count: count, success: success, failure: failure)
            break
        case .CacheFirst:
            fetchUserQuestionListUsingCacheByUserID(userID, page: page, count: count, success: success, failure: {
                error in
                self.fetchUserQuestionListUsingNetworkByUserID(userID, page: page, count: count, success: success, failure: failure)
            })
            break
        case .NetworkFirst:
            fetchUserQuestionListUsingNetworkByUserID(userID, page: page, count: count, success: success, failure: {
                error in
                self.fetchUserQuestionListUsingCacheByUserID(userID, page: page, count: count, success: success, failure: failure)
            })
            break
        default:
            break
        }
    }
    
    class func fetchUserQuestionListUsingCacheByUserID(userID: NSNumber, page: Int, count: Int, success: (([Question]) -> Void)?, failure: ((NSError) -> Void)?) {
        User_Question.fetchRelationshipsUsingCacheByUserID(userID,
            page: page,
            count: count,
            success: {
                user_questions in
                var questions = [Question]()
                for user_question in user_questions {
                    Question.fetchQuestionByID(user_question.questionID,
                        strategy: .CacheOnly,
                        success: {
                            question in
                            questions.append(question)
                        },
                        failure: failure)
                }
                success?(questions)
            },
            failure: failure)
    }
    
    class func fetchUserQuestionListUsingNetworkByUserID(userID: NSNumber, page: Int, count: Int, success: (([Question]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.GET("User Question List",
            parameters: [
                "uid": userID
            ],
            success: {
                data in
                var questions = [Question]()
                if (data["total_rows"] as NSString).integerValue > 0 {
                    var questionsData = [NSDictionary]()
                    if data["rows"] is NSDictionary {
                        questionsData = [data["rows"] as NSDictionary]
                    } else {
                        questionsData = data["rows"] as [NSDictionary]
                    }
                    for questionData in questionsData {
                        let question = Model.autoGenerateManagedObjectByEntityName("Question", ID: (questionData["id"] as NSString).integerValue) as Question
                        question.title = questionData["title"] as? String
                        question.body = questionData["detail"] as? String
                        User_Question.updateRelationship(userID: userID, questionID: question.id)
                        questions.append(question)
                    }
                }
                success?(questions)
            },
            failure: failure)
    }
    
    func toggleFocus(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        Model.GET("Focus Question",
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
