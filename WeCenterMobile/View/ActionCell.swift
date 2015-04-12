//
//  ActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class ActionCell: UITableViewCell {
    
    var action: Action!
    var actionChanged: Bool = true
    
    func update(#action: Action, updateImage: Bool) {
        actionChanged = action !== self.action
        self.action = action
    }
    
}
