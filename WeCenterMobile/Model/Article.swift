//
//  Article.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import CoreData

class Article: NSManagedObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var body: String?
    @NSManaged var id: NSNumber
    @NSManaged var title: String?
    @NSManaged var articleAgreementActions: NSSet
    @NSManaged var articlePublishmentActions: NSSet
    @NSManaged var featuredObject: FeaturedArticle
    @NSManaged var topics: NSSet
    @NSManaged var user: User?
    @NSManaged var comments: NSSet

}
