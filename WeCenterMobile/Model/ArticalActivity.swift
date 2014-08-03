//
//  ArticalActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/2.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class ArticalActivity: Activity {

    @NSManaged var commentCount: NSNumber
    
    convenience init() {
        let entity = NSEntityDescription.entityForName("ArticalActivity", inManagedObjectContext: appDelegate.managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
    }

}
