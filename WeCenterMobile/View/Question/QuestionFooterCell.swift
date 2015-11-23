//
//  QuestionFooterCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionFooterCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewCountImageView: UIImageView!
    @IBOutlet weak var focusCountImageView: UIImageView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var focusCountLabel: UILabel!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var focusActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var borderA: UIView!
    @IBOutlet weak var borderB: UIView!
    @IBOutlet weak var borderC: UIView!
    @IBOutlet weak var borderD: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        viewCountImageView.tintColor = theme.subtitleTextColor
        focusCountImageView.tintColor = theme.subtitleTextColor
        focusButton.msr_setBackgroundImageWithColor(theme.backgroundColorA, forState: .Highlighted)
        focusButton.setTitle(nil, forState: .Normal)
        focusButton.setTitleColor(theme.titleTextColor, forState: .Normal)
        containerView.backgroundColor = theme.backgroundColorB
        for v in [borderA, borderB, borderC, borderD] {
            v.backgroundColor = theme.borderColorA
        }
        viewCountLabel.textColor = theme.subtitleTextColor
        focusCountLabel.textColor = theme.subtitleTextColor
        focusActivityIndicatorView.color = theme.footnoteTextColor
    }
    
    func update(question question: Question) {
        let theme = SettingsManager.defaultManager.currentTheme
        viewCountLabel.text = "\(question.viewCount ?? 0)"
        focusCountLabel.text = "\(question.focusCount ?? 0)"
        if let focusing = question.focusing {
            focusButton.msr_setBackgroundImageWithColor(focusing ? theme.backgroundColorB : theme.backgroundColorA)
            focusButton.setTitle(focusing ? "已关注" : "关注", forState: .Normal)
            focusActivityIndicatorView.stopAnimating()
        } else {
            focusButton.setTitle(nil, forState: .Normal)
            focusActivityIndicatorView.startAnimating()
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
