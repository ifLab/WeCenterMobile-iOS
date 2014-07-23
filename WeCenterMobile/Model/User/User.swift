//
//  User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/19.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import CoreData

class Model {
    init(module: String, bundle: NSBundle) {}
    func fetch(success: (Msr.Data.Property) -> Void, failed: (Msr.Data.Property) -> Void) -> Void {
        var success: (Msr.Data.Property) -> Void = {
            println($0)
        }
//        func success(model: Msr.Data.Property) -> Void {
//            
//        }
    }
}

class User: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var uid: NSNumber
    
    let model = Model(module: "User", bundle: NSBundle.mainBundle())
    
    func login() {
        model.fetch({ model in }, failed: { model in })
    }

}
