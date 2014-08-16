//
//  User_Topic.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class User_Topic: NSManagedObject {

    @NSManaged var userID: NSNumber
    @NSManaged var topicID: NSNumber
    
    class func fetchRelationshipsUsingCacheByUserID(userID: NSNumber, page: Int, count: Int, success: (([User_Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("User_Topic_By_UserID", ID: userID, page: page, count: count, success: success, failure: failure)
    }

}
