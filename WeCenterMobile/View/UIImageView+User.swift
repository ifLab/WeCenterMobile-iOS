//
//  UIImageView+User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/30.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation

extension UIImageView {
    
    func wc_updateWithUser(user: User?) {
        msr_userInfo = user
        image = UIImage(named: "DefaultAvatar")
        if user?.avatar != nil {
            image = user!.avatar!
        }
        if user?.avatarURL != nil {
            user?.fetchAvatar(
                success: {
                    [weak self] in
                    if let self_ = self {
                        if let user_ = self_.msr_userInfo as? User {
                            if user_.id == user?.id {
                                self_.image = user!.avatar!
                            }
                        }
                    }
                },
                failure: {
                    error in
                    println(__FILE__, __FUNCTION__, error)
                    return
            })
        }
    }
    
}
