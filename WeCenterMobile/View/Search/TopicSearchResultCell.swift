//
//  TopicSearchResultCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/14.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class TopicSearchResultCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var topicImageView: UIImageView!
    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    @IBOutlet weak var topicButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, badgeLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        containerView.backgroundColor = theme.backgroundColorB
        badgeLabel.backgroundColor = theme.backgroundColorA
        topicTitleLabel.textColor = theme.titleTextColor
        topicDescriptionLabel.textColor = theme.subtitleTextColor
        badgeLabel.textColor = theme.footnoteTextColor
        topicButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
    }
    
    func update(dataObject dataObject: DataObject) {
        let topic = dataObject as! Topic
        topicTitleLabel.text = topic.title
        topicDescriptionLabel.text = topic.introduction ?? ""
        topicImageView.wc_updateWithTopic(topic)
        topicButton.msr_userInfo = topic
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}

