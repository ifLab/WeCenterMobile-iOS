//
//  UserCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/10.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var userButtonA: UIButton!
    @IBOutlet weak var userButtonB: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        msr_scrollView?.delaysContentTouches = false
        containerView.msr_borderColor = theme.borderColorA
        containerView.backgroundColor = theme.backgroundColorB
        userNameLabel.textColor = theme.titleTextColor
        userSignatureLabel.textColor = theme.subtitleTextColor
        userButtonB.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
    }

    func update(user user: User) {
        userAvatarView.wc_updateWithUser(user)
        userNameLabel.text = user.name
        /// @TODO: [Bug][Back-End] \n!!!
        userSignatureLabel.text = user.signature?.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        userButtonA.msr_userInfo = user
        userButtonB.msr_userInfo = user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
