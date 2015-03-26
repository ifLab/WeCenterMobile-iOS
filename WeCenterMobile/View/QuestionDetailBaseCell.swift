//
//  QuestionDetailBaseCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionDetailBaseCell: UITableViewCell {
    
    var object: AnyObject?
    var objectChanged: Bool = true
    
    func update(#object: AnyObject?) {
        if self.object !== object {
            objectChanged = true
        }
        self.object = object
    }
    
}
