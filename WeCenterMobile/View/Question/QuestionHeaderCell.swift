//
//  QuestionHeaderCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var borderA: UIView!
    @IBOutlet weak var borderB: UIView!
    @IBOutlet weak var borderC: UIView!
    @IBOutlet weak var borderD: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        userButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        for v in [borderA, borderB, borderC, borderD] {
            v.backgroundColor = theme.borderColorA
        }
        containerView.backgroundColor = theme.backgroundColorB
        userNameLabel.textColor = theme.titleTextColor
        userSignatureLabel.textColor = theme.subtitleTextColor
    }
    
    func update(user user: User?, updateImage: Bool) {
        if updateImage {
            userAvatarView.wc_updateWithUser(user)
        }
        userNameLabel.text = user?.name ?? "匿名用户"
        userSignatureLabel.text = user?.signature ?? ""
        userButton.msr_userInfo = user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
