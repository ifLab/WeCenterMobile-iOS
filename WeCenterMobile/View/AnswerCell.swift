//
//  AnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/29.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerCell: UITableViewCell {
    
    var answer: Answer?

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: MSRMultilineLabel!
    @IBOutlet weak var userAvatarView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
    }
    
    func update(#object: Answer) {
        answer = object
        if let answer = answer {
            userNameLabel.text = answer.user?.name ?? "匿名用户"
            answerBodyLabel.text = answer.body?.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.allZeros, range: nil)
            let user = answer.user
            userAvatarView.image = UIImage(named: "DefaultAvatar")
            userAvatarView.msr_userInfo = user
            if let avatar = user?.avatar {
                userAvatarView.image = avatar
            }
            if user?.avatarURL != nil {
                user?.fetchAvatar(
                    success: {
                        [weak self] in
                        if let user_ = self?.userAvatarView.msr_userInfo as? User {
                            if user_.id == user?.id {
                                self!.userAvatarView.image = user?.avatar
                            }
                        }
                    },
                    failure: {
                        error in
                        NSLog(__FILE__, __FUNCTION__, error)
                        return
                    })
            }
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
