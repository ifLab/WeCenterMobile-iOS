//
//  ActivityCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/3.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {
    
    let avatarView = UIImageView()
    let titleButton = UIButton()
    let answerAvatarView = UIImageView()
    let answerButton = UIButton()
    let viewCountLabel = UILabel()
    
    convenience init(activity: Activity, size: CGSize, reuseIdentifier: String!) {
        self.init(style: .Default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarView)
        contentView.addSubview(titleButton)
        contentView.addSubview(viewCountLabel)
        contentView.frame = CGRect(origin: CGPointZero, size: size)
        titleButton.frame = CGRect(x: 60, y: 10, width: contentView.bounds.width - 70, height: 40)
        titleButton.setTitle(activity.title, forState: .Normal)
        titleButton.setBackgroundImage(Msr.UI.Rectangle(color: UIColor.whiteColor(), size: titleButton.bounds.size).image, forState: .Normal)
        titleButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        titleButton.titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleButton.contentHorizontalAlignment = .Left
        titleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        titleButton.titleLabel.numberOfLines = 2
        avatarView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        avatarView.setImageWithURL(NSURL(string: activity.user.avatarURL))
        avatarView.layer.cornerRadius = avatarView.bounds.width / 2
        avatarView.layer.masksToBounds = true
        viewCountLabel.frame = CGRect(x: 10, y: 60, width: 40, height: 15)
        viewCountLabel.text = "\(activity.viewCount)"
        viewCountLabel.backgroundColor = UIColor(red: 222 / 255.0, green: 86 / 255.0, blue: 18 / 255.0, alpha: 1)
        viewCountLabel.font = UIFont.systemFontOfSize(10)
        viewCountLabel.textColor = UIColor.whiteColor()
        viewCountLabel.textAlignment = .Center
        if let questionActivity = activity as? QuestionActivity {
            if questionActivity.answerUser != nil {
                contentView.addSubview(answerAvatarView)
                answerAvatarView.frame = CGRect(x: 60, y: 60, width: 25, height: 25)
                answerAvatarView.layer.cornerRadius = answerAvatarView.bounds.width / 2
                answerAvatarView.layer.masksToBounds = true
                answerAvatarView.setImageWithURL(NSURL(string: questionActivity.answerUser!.avatarURL))
            }
            if questionActivity.answerContent != nil {
                contentView.addSubview(answerButton)
                answerButton.frame = CGRect(x: 90, y: 60, width: contentView.bounds.width - 100, height: 50)
                answerButton.setTitle(questionActivity.answerContent, forState: .Normal)
                answerButton.setBackgroundImage(Msr.UI.Rectangle(color: UIColor.whiteColor(), size: answerButton.bounds.size).image, forState: .Normal)
                answerButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
                answerButton.titleLabel.font = UIFont.systemFontOfSize(14)
                answerButton.titleLabel.numberOfLines = 3
                answerButton.contentHorizontalAlignment = .Left
                answerButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            }
        } else {
            
        }
    }
    
}
