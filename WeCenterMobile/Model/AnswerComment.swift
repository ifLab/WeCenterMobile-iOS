//
//  AnswerComment.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class AnswerComment: NSManagedObject {

    @NSManaged var atID: NSNumber?
    @NSManaged var body: String?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber
    @NSManaged var answer: Answer?
    @NSManaged var atUser: User?
    @NSManaged var user: User?
    
    func post(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.request("Post Answer Comment",
            GETParameters: ["answer_id": answer!.id],
            POSTParameters: ["message": body!],
            constructingBodyWithBlock: nil,
            success: {
                data in
                success?()
                return
            },
            failure: failure)
    }

}
