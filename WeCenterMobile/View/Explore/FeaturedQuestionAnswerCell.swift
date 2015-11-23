//
//  FeaturedQuestionAnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedQuestionAnswerCell: UITableViewCell {
    
    @IBOutlet weak var questionUserAvatarView: MSRRoundedImageView!
    @IBOutlet weak var questionUserNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerUserAvatarView: MSRRoundedImageView?
    @IBOutlet weak var answerBodyLabel: UILabel?
    @IBOutlet weak var answerUserNameLabel: UILabel?
    @IBOutlet weak var questionBadgeLabel: UILabel!
    @IBOutlet weak var answerBadgeLabel: UILabel?
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answerButton: UIButton?
    @IBOutlet weak var questionUserButton: UIButton!
    @IBOutlet weak var answerUserButton: UIButton?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorA: UIView!
    @IBOutlet weak var separatorB: UIView?
    @IBOutlet weak var separatorC: UIView?
    @IBOutlet weak var questionUserContainerView: UIView!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var answerUserContainerView: UIView?
    @IBOutlet weak var answerContainerView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, questionBadgeLabel, answerBadgeLabel] {
            v?.msr_borderColor = theme.borderColorA
        }
        for v in [separatorA, separatorB, separatorC] {
            v?.backgroundColor = theme.borderColorA
        }
        for v in [questionButton, questionUserButton, answerButton, answerUserButton] {
            v?.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [questionUserContainerView, questionContainerView, answerUserContainerView, answerContainerView] {
            v?.backgroundColor = theme.backgroundColorB
        }
        for v in [questionBadgeLabel, answerBadgeLabel] {
            v?.backgroundColor = theme.backgroundColorA
            v?.textColor = theme.footnoteTextColor
        }
        for v in [questionUserNameLabel, questionTitleLabel, answerUserNameLabel] {
            v?.textColor = theme.titleTextColor
        }
        answerBodyLabel?.textColor = theme.subtitleTextColor
    }
    
    func update(object object: FeaturedObject) {
        let object = object as! FeaturedQuestionAnswer
        let question = object.question!
        let answer = object.answers.first
        questionUserAvatarView.wc_updateWithUser(question.user)
        answerUserAvatarView?.wc_updateWithUser(answer?.user)
        questionUserNameLabel.text = question.user?.name
        questionTitleLabel.text = question.title
        answerUserNameLabel?.text = answer?.user?.name ?? "匿名用户"
        answerBodyLabel?.text = answer?.body!.wc_plainString
        questionButton.msr_userInfo = question
        answerButton?.msr_userInfo = answer
        questionUserButton.msr_userInfo = question.user
        answerUserButton?.msr_userInfo = answer?.user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
