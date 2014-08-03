//
//  TopicDetailCell.swift
//  WeCenterMobile
//
//  Created by Jerry Black on 14-7-25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicDetailCell: UITableViewCell {
    var topicImageView: UIImageView
    var titleLabel: UILabel
    var introductLabel: UILabel
    var followersLabel: UILabel
    var followersTextLabel: UILabel
    var followButton: UIButton
    
    init() {
        topicImageView = UIImageView()
        titleLabel = UILabel()
        introductLabel = UILabel()
        followersLabel = UILabel()
        followersTextLabel = UILabel()
        followButton = UIButton()
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    }
    
    class func getFirstCell(topic: Topic, reuseIdentifier: String!) -> TopicDetailCell {
        var cell = TopicDetailCell()
        
        cell.titleLabel.frame     = CGRectMake(74.0, 8.0, 230.0, 18.0)
        cell.titleLabel.font      = UIFont.systemFontOfSize(15.0)
        cell.titleLabel.textColor = UIColor.darkTextColor()
        cell.titleLabel.text      = topic.title
        cell.addSubview(cell.titleLabel)
        
        cell.introductLabel.frame         = CGRectMake(12.0, 66.0, UIScreen.mainScreen().bounds.width - 24, 50.0)
        cell.introductLabel.font          = UIFont.systemFontOfSize(13.0)
        cell.introductLabel.textColor     = UIColor.grayColor()
        cell.introductLabel.text          = topic.introduct
        cell.introductLabel.numberOfLines = 0;
        cell.introductLabel.sizeToFit()
        cell.introductLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell.addSubview(cell.introductLabel)
        
        cell.topicImageView.frame               = CGRectMake(12.0, 8.0, 50.0, 50.0)
        cell.topicImageView.backgroundColor     = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        cell.topicImageView.contentMode         = UIViewContentMode.ScaleAspectFill
        cell.topicImageView.clipsToBounds       = true
        cell.topicImageView.image               = UIImage(named: "400")
        cell.topicImageView.layer.cornerRadius  = cell.topicImageView.bounds.size.height / 2
        cell.topicImageView.layer.masksToBounds = true
        cell.insertSubview(cell.topicImageView, aboveSubview: cell.introductLabel)
        
        return cell
    }
    
    class func getSecondCell(topic: Topic, reuseIdentifier: String!) -> TopicDetailCell {
        var cell = TopicDetailCell()
        
        cell.followersLabel.frame     = CGRectMake(20.0, 14.0, 200.0, 16.0)
        cell.followersLabel.font      = UIFont.systemFontOfSize(15.0)
        cell.followersLabel.textColor = UIColor.darkTextColor()
        println("\(topic.followers)人关注")
        cell.followersLabel.text      = "\(topic.followers)"
        cell.followersLabel.numberOfLines = 1;
        cell.followersLabel.sizeToFit()
        cell.addSubview(cell.followersLabel)
        
        cell.followersTextLabel.frame     = CGRectMake(cell.followersLabel.frame.size.width + 20.0, 15.0, 50.0, 16.0)
        cell.followersTextLabel.font      = UIFont.systemFontOfSize(12.0)
        cell.followersTextLabel.textColor = UIColor.grayColor()
        cell.followersTextLabel.text      = "人关注"
        cell.addSubview(cell.followersTextLabel)
        
        cell.followButton.frame = CGRectMake(235.0, 10.0, 75.0, 30.0)
        cell.followButton.titleLabel.font = UIFont.systemFontOfSize(14.0)
        cell.addSubview(cell.followButton)
        
        return cell
    }
    
}
