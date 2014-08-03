//
//  Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/2.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Topic: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    
    convenience init() {
        let entity = NSEntityDescription.entityForName("Topic", inManagedObjectContext: appDelegate.managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
    }

}
