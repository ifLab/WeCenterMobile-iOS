//
//  FeaturedObjectCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedObjectCell: UITableViewCell {
    var object: FeaturedObject?
    var objectChanged: Bool = true
    func update(#object: FeaturedObject) {
        objectChanged = self.object !== object
        self.object = object
    }
}
