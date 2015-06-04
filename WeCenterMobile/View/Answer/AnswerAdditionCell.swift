//
//  AnswerAdditionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/29.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerAdditionCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var answerAdditionImageView: UIImageView!
    @IBOutlet weak var answerAdditionLabel: UILabel!
    @IBOutlet weak var answerAdditionButton: UIButton!
    @IBOutlet weak var borderA: UIView!
    @IBOutlet weak var borderB: UIView!
    @IBOutlet weak var borderC: UIView!
    @IBOutlet weak var borderD: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        answerAdditionImageView.msr_imageRenderingMode = .AlwaysTemplate
        answerAdditionImageView.tintColor = theme.subtitleTextColor
        answerAdditionLabel.textColor = theme.subtitleTextColor
        answerAdditionButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        containerView.backgroundColor = theme.backgroundColorB
        for v in [borderA, borderB, borderC, borderD] {
            v.backgroundColor = theme.borderColorA
        }
    }

}
