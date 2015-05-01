//
//  ArticleComment.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class ArticleComment: NSManagedObject {

    @NSManaged var atID: NSNumber?
    @NSManaged var body: String?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber
    @NSManaged var atUser: User?
    @NSManaged var article: Article?
    @NSManaged var user: User?

}
