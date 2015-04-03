//
//  QuestionHeaderCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
    }
    
    func update(#user: User?) {
        userAvatarView.wc_updateWithUser(user)
        userNameLabel.text = user?.name ?? "匿名用户"
        userSignatureLabel.text = user?.signature ?? ""
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
