//
//  AnswerComment.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import CoreData

class AnswerComment: NSManagedObject {

    @NSManaged var atID: NSNumber?
    @NSManaged var body: String?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber
    @NSManaged var answer: Answer?
    @NSManaged var atUser: User?
    @NSManaged var user: User?
    
    class func post(#answerID: NSNumber, body: String, atUserName: String?, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.POST("Post Answer Comment",
            parameters: [
                "answer_id": answerID,
                "message": body
            ],
            success: {
                data in
                println(data)
                success?()
            },
            failure: failure)
    }

}
