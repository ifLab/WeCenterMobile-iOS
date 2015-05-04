//
//  ArticleComment.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class ArticleComment: Comment {
    
    @NSManaged var article: Article?
    @NSManaged var agreementCount: NSNumber?
    
    var evaluation: Evaluation?
    
    func post(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        var POSTParameters: [NSObject: AnyObject] = ["message": body!]
        if atUser != nil {
            POSTParameters = ["at_uid": atUser!.id]
        }
        NetworkManager.defaultManager!.request("Post Article Comment",
            GETParameters: ["article_id": article!.id],
            POSTParameters: POSTParameters,
            constructingBodyWithBlock: nil,
            success: {
                [weak self] data in
                success?()
                return
            },
            failure: failure)
    }

}
