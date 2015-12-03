//
//  Action.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import CoreData
import Foundation

enum ActionTypeID: Int {
    case QuestionPublishment = 101
    case QuestionFocusing = 105
    case Answer = 201
    case AnswerAgreement = 204
    case ArticlePublishment = 501
    case ArticleAgreement = 502
    case ArticleCommentary = 503
}

class Action: DataObject {

    @NSManaged var date: NSDate?
    @NSManaged var user: User?
    
}
