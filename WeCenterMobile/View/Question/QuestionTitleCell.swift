//
//  QuestionTitleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionTitleCell: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var borderA: UIView!
    @IBOutlet weak var borderB: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        containerView.backgroundColor = theme.backgroundColorB
        questionTitleLabel.textColor = theme.titleTextColor
        for v in [borderA, borderB] {
            v.backgroundColor = theme.borderColorA
        }
    }
    
    func update(question question: Question) {
        questionTitleLabel.text = question.title ?? "加载中"
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
