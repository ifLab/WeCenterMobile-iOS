//
//  UserSearchResultCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/14.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserSearchResultCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, badgeLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        containerView.backgroundColor = theme.backgroundColorB
        badgeLabel.backgroundColor = theme.backgroundColorA
        userNameLabel.textColor = theme.titleTextColor
        userSignatureLabel.textColor = theme.subtitleTextColor
        badgeLabel.textColor = theme.footnoteTextColor
        userButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
    }
    
    func update(dataObject dataObject: DataObject) {
        let user = dataObject as! User
        userNameLabel.text = user.name
        userSignatureLabel.text = user.signature ?? ""
        userAvatarView.wc_updateWithUser(user)
        userButton.msr_userInfo = user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
