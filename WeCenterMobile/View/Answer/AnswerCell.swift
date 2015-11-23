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
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var agreementCountLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var answerContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, agreementCountLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        for v in [userButton, answerButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [agreementCountLabel, answerBodyLabel] {
            v.textColor = theme.subtitleTextColor
        }
        for v in [userContainerView, answerContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        agreementCountLabel.backgroundColor = theme.backgroundColorA
        separator.backgroundColor = theme.borderColorA
        userNameLabel.textColor = theme.titleTextColor
    }
    
    func update(answer answer: Answer, updateImage: Bool) {
        self.answer = answer
        userNameLabel.text = answer.user?.name ?? "匿名用户"
        answerBodyLabel.text = answer.body?.wc_plainString
        agreementCountLabel.text = "\(answer.agreementCount ?? 0)"
        userButton.msr_userInfo = answer.user
        answerButton.msr_userInfo = answer
        if updateImage {
            userAvatarView.wc_updateWithUser(answer.user)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
