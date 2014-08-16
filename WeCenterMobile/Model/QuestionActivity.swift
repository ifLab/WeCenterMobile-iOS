//
//  QuestionActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/3.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class QuestionActivity: Activity {

    @NSManaged var answerCount: NSNumber?
    @NSManaged var focusCount: NSNumber?
    @NSManaged var lastUpdatedTime: NSDate?
    @NSManaged var answerUserID: NSNumber?
    @NSManaged var answerContent: String?
    
    var answerUser: User? = nil
    var topics = [Topic]()
    
}
