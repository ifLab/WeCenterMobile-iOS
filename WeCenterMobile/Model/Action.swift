//
//  Action.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

enum ActionTypeID: Int {
    case QuestionPublishment = 101
    case QuestionFocusing = 105
    case Answer = 201
    case AnswerAgreement = 204
    case ArticlePublishment = 501
    case ArticleAgreement = 502
}

class Action: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var id: NSNumber
    @NSManaged var user: User?
    
    class func get(#ID: NSNumber, error: NSErrorPointer) -> Action? {
        return DataManager.defaultManager!.fetch("Action", ID: ID, error: error) as? Action
    }
    
}
