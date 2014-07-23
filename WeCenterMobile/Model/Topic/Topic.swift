//
//  Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/22.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Topic: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var date: NSDate

}
