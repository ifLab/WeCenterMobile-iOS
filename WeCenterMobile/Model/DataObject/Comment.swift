//
//  Comment.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/4.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class Comment: DataObject {
    
    @NSManaged var atID: NSNumber?
    @NSManaged var body: String?
    @NSManaged var date: NSDate?
    @NSManaged var atUser: User?
    @NSManaged var user: User?
    
    func post(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {}

}
