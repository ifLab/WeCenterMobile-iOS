//
//  AnswerActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/28.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerActionCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var agreementCountLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var answerContainerView: UIView!
    @IBOutlet weak var separatorA: UIView!
    @IBOutlet weak var separatorB: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, agreementCountLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        for v in [userButton, questionButton, answerButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userContainerView, questionContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        for v in [agreementCountLabel, answerContainerView] {
            v.backgroundColor = theme.backgroundColorA
        }
        for v in [separatorA, separatorB] {
            v.backgroundColor = theme.borderColorA
        }
        for v in [userNameLabel, questionTitleLabel] {
            v.textColor = theme.titleTextColor
        }
        for v in [agreementCountLabel, typeLabel, answerBodyLabel] {
            v.textColor = theme.subtitleTextColor
        }
    }
    
    func update(action action: Action) {
        let action = action as! AnswerAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        questionTitleLabel.text = action.answer!.question!.title!
        agreementCountLabel.text = "\(action.answer!.agreementCount!)"
        answerBodyLabel.text = action.answer!.body!.wc_plainString
        userButton.msr_userInfo = action.user
        questionButton.msr_userInfo = action.answer!.question
        answerButton.msr_userInfo = action.answer
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
