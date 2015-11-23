//
//  QuestionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/28.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionBodyLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separator: UIView!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        containerView.msr_borderColor = theme.borderColorA
        separator.backgroundColor = theme.borderColorA
        for v in [userContainerView, questionContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        for v in [userButton, questionButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, questionTitleLabel] {
            v.textColor = theme.titleTextColor
        }
        dateLabel.textColor = theme.footnoteTextColor
        questionBodyLabel.textColor = theme.subtitleTextColor
    }
    
    func update(question question: Question) {
        questionTitleLabel.text = question.title
        questionBodyLabel.text = question.body?.wc_plainString ?? ""
        userNameLabel.text = question.user?.name ?? "匿名用户"
        if let date = question.date {
            dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        userAvatarView.wc_updateWithUser(question.user)
        userButton.msr_userInfo = question.user
        questionButton.msr_userInfo = question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
