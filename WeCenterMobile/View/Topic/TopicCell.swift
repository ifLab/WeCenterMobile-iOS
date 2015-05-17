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
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        topicButtonB.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#topic: Topic, updateImage: Bool) {
        if updateImage {
            topicImageView.wc_updateWithTopic(topic)
        }
        topicTitleLabel.text = topic.title
        /// @TODO: [Back-End][Bug] \n!!!
        topicDescriptionLabel.text = topic.introduction?.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        topicButtonA.msr_userInfo = topic
        topicButtonB.msr_userInfo = topic
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
