//
//  TopicListViewControllerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/11.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class TopicListViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var topicImageView: UIImageView!
    @IBOutlet weak var topicTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topicImageView.layer.cornerRadius = topicImageView.bounds.width / 2
        topicImageView.layer.masksToBounds = true
        selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    }
    
    func update(#topic: Topic) {
        topicImageView.wc_updateWithTopic(topic)
        let text = NSMutableAttributedString(
            string: topic.title!,
            attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(16),
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        if topic.introduction ?? "" != "" {
            text.appendAttributedString(NSAttributedString(
                string: "，" + topic.introduction!,
                attributes: [
                    NSFontAttributeName: UIFont.systemFontOfSize(16),
                    NSForegroundColorAttributeName: UIColor.lightTextColor()]))
        }
        topicTitleLabel.attributedText = text
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
