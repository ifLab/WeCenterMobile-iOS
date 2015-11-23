//
//  AnswerCellWithQuestionTitle.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/12.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerCellWithQuestionTitle: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerUserAvatarView: MSRRoundedImageView!
    @IBOutlet weak var answerUserNameLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: UILabel!
    @IBOutlet weak var answerAgreementCountLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var answerContainerView: UIView!
    @IBOutlet weak var separatorA: UIView!
    @IBOutlet weak var separatorB: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        msr_scrollView?.delaysContentTouches = false
        for v in [containerView, answerAgreementCountLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        for v in [separatorA, separatorB] {
            v.backgroundColor = theme.borderColorA
        }
        for v in [questionContainerView, userContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        for v in [answerContainerView, answerAgreementCountLabel] {
            v.backgroundColor = theme.backgroundColorA
        }
        for v in [questionButton, userButton, answerButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [answerBodyLabel, answerAgreementCountLabel] {
            v.textColor = theme.subtitleTextColor
        }
        questionTitleLabel.textColor = theme.titleTextColor
    }
    
    func update(answer answer: Answer) {
        questionTitleLabel.text = answer.question!.title
        answerUserAvatarView.wc_updateWithUser(answer.user)
        let theme = SettingsManager.defaultManager.currentTheme
        let text = NSMutableAttributedString(string: answer.user?.name ?? "匿名用户", attributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(14),
            NSForegroundColorAttributeName: theme.titleTextColor])
        if let signature = answer.user?.signature?.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()) {
            text.appendAttributedString(NSAttributedString(string: "，" + signature, attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: theme.footnoteTextColor]))
        }
        answerUserNameLabel.attributedText = text
        answerBodyLabel.text = answer.body!.wc_plainString
        answerAgreementCountLabel.text = answer.agreementCount?.description ?? "0"
        questionButton.msr_userInfo = answer.question
        answerButton.msr_userInfo = answer
        userButton.msr_userInfo = answer.user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
