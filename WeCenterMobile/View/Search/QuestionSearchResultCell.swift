//
//  QuestionSearchResultCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/14.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionSearchResultCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, badgeLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        containerView.backgroundColor = theme.backgroundColorB
        badgeLabel.backgroundColor = theme.backgroundColorA
        questionTitleLabel.textColor = theme.titleTextColor
        badgeLabel.textColor = theme.footnoteTextColor
        questionButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
    }
    
    func update(dataObject dataObject: DataObject) {
        let question = dataObject as! Question
        questionTitleLabel.text = question.title ?? ""
        questionButton.msr_userInfo = question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
