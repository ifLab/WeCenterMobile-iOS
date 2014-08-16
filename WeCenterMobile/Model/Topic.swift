//
//  Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Topic: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var id: NSNumber
    @NSManaged var introduction: String
    @NSManaged var image: String
    @NSManaged var focusCount: NSNumber

}
