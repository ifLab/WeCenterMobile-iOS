//
//  ActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class ActionCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    
    func update(#action: Action) {
        userNameButton.setTitle(action.user.name, forState: .Normal)
        userAvatarView.image = action.user.avatar
        userNameButton.msr_userInfo = action.user
    }
    
}