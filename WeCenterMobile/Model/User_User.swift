//
//  User_User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class User_User: NSManagedObject {

    @NSManaged var a: NSNumber
    @NSManaged var b: NSNumber
    
    class func updateRelationship(#a: NSNumber, b: NSNumber) {
        if !relationshipExists(a: a, b: b) {
            let user_user = Model.createManagedObjecWithEntityName("User_User") as User_User
            user_user.a = a
            user_user.b = b
            appDelegate.saveContext()
        }
    }
    
    class func fetchRelationshipsUsingCacheByUserAID(a: NSNumber, page: Int, count: Int, success: (([User_User]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("User_User_By_UserAID", ID: a, page: page, count: count, success: success, failure: failure)
    }
    
    class func fetchRelationshipsUsingCacheByUserBID(b: NSNumber, page: Int, count: Int, success: (([User_Topic]) -> Void)?, failure: ((NSError) -> Void)?) {
        Model.fetchRelationshipsByTemplateName("User_User_By_UserBID", ID: b, page: page, count: count, success: success, failure: failure)
    }
    
    class func relationshipExists(#a: NSNumber, b: NSNumber) -> Bool {
        return Model.relationshipExists("User_User_Check", a: ("UserAID", a), b: ("UserBID", b))
    }


}
