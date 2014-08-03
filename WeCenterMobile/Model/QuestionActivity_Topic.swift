//
//  QuestionActivity_Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/3.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class QuestionActivity_Topic: NSManagedObject {

    @NSManaged var questionActivityID: NSNumber
    @NSManaged var topicID: NSNumber
    
    convenience init() {
        let entity = NSEntityDescription.entityForName("QuestionActivity_Topic", inManagedObjectContext: appDelegate.managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
    }

}
