//
//  Answer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Answer: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var userID: NSNumber
    @NSManaged var agreementCount: NSNumber
    @NSManaged var body: String
    @NSManaged var commentCount: NSNumber
    @NSManaged var date: NSDate

}
