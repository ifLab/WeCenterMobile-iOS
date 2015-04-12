//
//  UIImageView+User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/30.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation

let defaultUserAvatar = UIImage(named: "DefaultAvatar")!
let defaultTopicImage = UIImage(named: "User_Follow")!

extension UIImageView {
    
    func wc_updateWithUser(user: User?) {
        msr_userInfo = user
        image = defaultUserAvatar
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
                    return
                },
                failure: nil)
        }
    }
    
    func wc_updateWithTopic(topic: Topic?) {
        msr_userInfo = topic
        image = defaultTopicImage
        if topic?.image != nil {
            image = topic!.image!
        }
        if topic?.imageURL != nil {
            topic?.fetchImage(
                success: {
                    [weak self] in
                    if let self_ = self {
                        if let topic_ = self_.msr_userInfo as? Topic {
                            if topic_.id == topic?.id {
                                self_.image = topic!.image!
                            }
                        }
                    }
                    return
                },
                failure: nil)
        }
    }
    
}
