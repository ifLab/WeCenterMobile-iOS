//
//  TopicCell.swift
//  WeCenterMobile
//
//  Created by Jerry Black on 14-7-16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicCell: UITableViewCell {
    
    var topicImageView: UIImageView
    var titleLabel: UILabel
    var introductLabel: UILabel
    
    init(topic: Topic, reuseIdentifier: String!) {
        topicImageView = UIImageView()
        titleLabel = UILabel()
        introductLabel = UILabel()
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        titleLabel.frame     = CGRectMake(74.0, 8.0, 230.0, 18.0)
        titleLabel.font      = UIFont.systemFontOfSize(15.0)
        titleLabel.textColor = UIColor.darkTextColor()
        addSubview(titleLabel)
        
        introductLabel.frame         = CGRectMake(74.0, 20.0, 230.0, 50.0)
        introductLabel.font          = UIFont.systemFontOfSize(13.0)
        introductLabel.numberOfLines = 2;
        introductLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        introductLabel.textColor     = UIColor.grayColor()
        addSubview(introductLabel)
        
        topicImageView.frame           = CGRectMake(12.0, 8.0, 50.0, 50.0)
        topicImageView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        topicImageView.contentMode     = UIViewContentMode.ScaleAspectFill
        topicImageView.clipsToBounds   = true
        insertSubview(topicImageView, aboveSubview: introductLabel)
        
        titleLabel.text = topic.title
        introductLabel.text = topic.introduct
        topicImageView.image = UIImage(named: "400")
        topicImageView.layer.cornerRadius = topicImageView.bounds.size.height / 2
        topicImageView.layer.masksToBounds = true
    }
    
    required init(coder aDecoder: NSCoder!) {
        topicImageView = aDecoder.decodeObjectForKey("topicImageView") as UIImageView
        titleLabel = aDecoder.decodeObjectForKey("titleLabel") as UILabel
        introductLabel = aDecoder.decodeObjectForKey("introductLabel") as UILabel
        super.init(coder: aDecoder)
    }
    
}
