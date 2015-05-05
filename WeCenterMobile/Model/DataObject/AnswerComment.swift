//
//  AnswerComment.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class AnswerComment: Comment {

    @NSManaged var answer: Answer?
    
    override func post(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        super.post(success: success, failure: failure)
        var body = self.body!
        if let user = atUser {
            body = "@" + user.name! + ":" + body
        }
        NetworkManager.defaultManager!.request("Post Answer Comment",
            GETParameters: ["answer_id": answer!.id],
            POSTParameters: ["message": body],
            constructingBodyWithBlock: nil,
            success: {
                [weak self] data in
                success?()
                return
            },
            failure: failure)
    }

}
