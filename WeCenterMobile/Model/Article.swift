//
//  Article.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/7.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Article: NSManagedObject {

    @NSManaged var agreementCount: NSNumber
    @NSManaged var body: String
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var articleAgreementActions: NSSet
    @NSManaged var articlePublishmentActions: NSSet
    @NSManaged var topics: NSSet
    @NSManaged var user: User

}
