//
//  QuestionPublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionPublishmentActionCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [userContainerView, questionContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        containerView.msr_borderColor = theme.borderColorA
        separator.backgroundColor = theme.borderColorA
        for v in [userButton, questionButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, questionTitleLabel] {
            v.textColor = theme.titleTextColor
        }
        typeLabel.textColor = theme.subtitleTextColor
    }
    
    func update(action action: Action) {
        let action = action as! QuestionPublishmentAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        questionTitleLabel.text = action.question!.title!
        userButton.msr_userInfo = action.user
        questionButton.msr_userInfo = action.question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
