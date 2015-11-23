//
//  TopicCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/11.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class TopicCell: UITableViewCell {
    
    @IBOutlet weak var topicImageView: MSRRoundedImageView!
    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    @IBOutlet weak var topicButtonA: UIButton!
    @IBOutlet weak var topicButtonB: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        msr_scrollView?.delaysContentTouches = false
        containerView.msr_borderColor = theme.borderColorA
        containerView.backgroundColor = theme.backgroundColorB
        topicTitleLabel.textColor = theme.titleTextColor
        topicDescriptionLabel.textColor = theme.subtitleTextColor
        topicButtonB.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
    }
    
    func update(topic topic: Topic) {
        topicImageView.wc_updateWithTopic(topic)
        topicTitleLabel.text = topic.title
        /// @TODO: [Bug][Back-End] \n!!!
        topicDescriptionLabel.text = topic.introduction?.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        topicButtonA.msr_userInfo = topic
        topicButtonB.msr_userInfo = topic
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
