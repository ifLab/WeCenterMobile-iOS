//
//  UserMaimCell.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

let UserStrings = Msr.Data.LocalizedStrings(module: "User", bundle: NSBundle.mainBundle())

class UserMainCell: UITableViewCell {
    var avatarView = UIImageView()
    var nameLabel = UILabel()
    var myTopicButton = UIButton()
    var myTopicCountLabel = UILabel()
    var followingButton = UIButton()
    var followingCountLabel = UILabel()
    var followerButton = UIButton()
    var followerCountLabel = UILabel()
    var likeView = UIImageView()
    var likeCount = UILabel()
    var thankView = UIImageView()
    var thankCount = UILabel()
    var favoriteView = UIImageView()
    var favoriteCount = UILabel()
    var introduction = UILabel()
    var cellHeight:CGFloat?
    init(user: User, reuseIndentifer: String!) {
        super.init(style: .Default, reuseIdentifier: reuseIndentifer)
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(myTopicButton)
        contentView.addSubview(followingButton)
        contentView.addSubview(followerButton)
        contentView.addSubview(likeView)
        contentView.addSubview(likeCount)
        contentView.addSubview(thankView)
        contentView.addSubview(thankCount)
        contentView.addSubview(favoriteView)
        contentView.addSubview(favoriteCount)
        contentView.addSubview(introduction)
        
        myTopicButton.addSubview(myTopicCountLabel)
        followingButton.addSubview(followingCountLabel)
        followerButton.addSubview(followerCountLabel)
        
        avatarView.frame = CGRect(x: 10, y: 15, width: 76, height: 76)
        avatarView.setImageWithURL(NSURL(string: user.avatarURL))
        avatarView.layer.cornerRadius = avatarView.bounds.width / 2
        avatarView.layer.masksToBounds = true
        
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.frame = CGRect(x: 96, y: 15, width: 200, height: 20)
        nameLabel.font = UIFont.boldSystemFontOfSize(16)
        
        
       
        
        myTopicButton.setTitle(UserStrings["My topics"], forState: .Normal) // UserStrings["My Topics"]
        myTopicButton.titleLabel.textAlignment = .Left
        myTopicButton.titleLabel.font = UIFont.systemFontOfSize(10)
        myTopicButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        myTopicButton.frame = CGRect(x: 86, y: 45, width: 60, height: 65)
        myTopicButton.setBackgroundImage(Msr.UI.Rectangle(color: UIColor.whiteColor(), size: myTopicButton.bounds.size).image, forState: .Normal)
        
        myTopicCountLabel.frame = CGRect(x: 11, y: 10, width: 56, height: 13)
        myTopicCountLabel.font = UIFont.systemFontOfSize(13)
        myTopicCountLabel.textColor = UIColor.darkTextColor()
        myTopicCountLabel.text = "\(user.topicFocusCount!)"
   
        followingButton.frame = CGRectMake(163, 45, 65, 65)
        followingButton.setTitle(UserStrings["I focus on"], forState: .Normal)
        followingButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        followingButton.titleLabel.font = UIFont.systemFontOfSize(10)
        followingButton.setBackgroundImage(Msr.UI.Rectangle(color: UIColor.whiteColor(), size: followingButton.bounds.size).image, forState: .Normal)
        
        followingCountLabel.frame = CGRect(x: 7, y: 10, width: 60, height: 13)
        followingCountLabel.font = UIFont.systemFontOfSize(13)
        followingCountLabel.textColor = UIColor.darkTextColor()
        followingCountLabel.text = "\(user.followingCount!)"
        
        followerButton.frame = CGRect(x: 239, y: 45, width: 65, height: 65)
        followerButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        followerButton.setTitle(UserStrings["Watch me"], forState: .Normal)
        followerButton.titleLabel.font = UIFont.systemFontOfSize(10)
        followerButton.setBackgroundImage(Msr.UI.Rectangle(color: UIColor.whiteColor(), size: followerButton.bounds.size).image, forState: .Normal)
        
        followerCountLabel.frame = CGRect(x: 8, y: 10, width: 60, height: 13)
        followerCountLabel.font = UIFont.systemFontOfSize(13)
        followerCountLabel.textColor = UIColor.darkTextColor()
        followerCountLabel.text = "\(user.followerCount!)"
        
        introduction.frame.origin = CGPoint(x: avatarView.frame.origin.x + 2, y: avatarView.frame.origin.y + avatarView.frame.height + 5)
        introduction.font = UIFont.systemFontOfSize(13)
        introduction.textColor = UIColor.darkTextColor()
        introduction.text = "sdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0"
        introduction.frame = CGRectMake(  avatarView.frame.origin.x, avatarView.frame.origin.y + avatarView.frame.height + 5, 300, 20)
        introduction.lineBreakMode = NSLineBreakMode.ByWordWrapping
        introduction.numberOfLines = 0;
        introduction.sizeToFit()

        
        let line4 = UIView(frame: CGRectMake(0, introduction.frame.origin.y + introduction.frame.height + 5, 320, 0.6))
        line4.backgroundColor = UIColor.lightGrayColor()
        contentView.addSubview(line4)

        likeView.frame = CGRect(x:10, y: line4.frame.origin.y + 8, width: 18, height: 18)
        likeView.backgroundColor = UIColor.grayColor()

        
        likeCount.frame = CGRect(x: likeView.frame.origin.x + 21, y: line4.frame.origin.y + 9, width: 30, height: 18)
        likeCount.font = UIFont.systemFontOfSize(13)
        likeCount.textColor = UIColor.grayColor()
        likeCount.text = "\(user.agreementCount!)"
        likeCount.sizeToFit()
        
        thankView.frame = CGRect(x: likeCount.frame.origin.x + likeCount.frame.width + 21, y: line4.frame.origin.y + 8, width: 18, height: 18)
        thankView.backgroundColor = UIColor.grayColor()
        
        thankCount.frame = CGRectMake(thankView.frame.origin.x + 21, line4.frame.origin.y + 9, 30, 18)
        thankCount.font = UIFont.systemFontOfSize(13)
        thankCount.textColor = UIColor.grayColor()
        thankCount.text = "\(user.thankCount!)"
        thankCount.sizeToFit()
        
        favoriteView.frame = CGRect(x: thankCount.frame.origin.x + thankCount.frame.width + 21, y: line4.frame.origin.y + 8, width: 18, height: 18)
        favoriteView.backgroundColor = UIColor.grayColor()
        
        favoriteCount.frame = CGRect(x: favoriteView.frame.origin.x + 21, y: line4.frame.origin.y + 9, width: 30, height: 18)
        favoriteCount.textColor = UIColor.grayColor()
        favoriteCount.font = UIFont.systemFontOfSize(13)
        favoriteCount.text = "\(user.answerFavoriteCount!)"
        favoriteCount.sizeToFit()
        
        let line1 = UIView(frame: CGRectMake(96, 38, 226, 0.6))
        line1.backgroundColor = UIColor.lightGrayColor()
        contentView.addSubview(line1)
        let line2 = UIView()
        line2.backgroundColor = UIColor.lightGrayColor()
        let line3 = UIView()
        line3.backgroundColor = UIColor.lightGrayColor()
        line2.frame = CGRectMake(myTopicButton.frame.origin.x + myTopicButton.frame.width + 10, followingButton.frame.origin.y, 0.6, 45)
        line3.frame = CGRectMake(followingButton.frame.origin.x + followingButton.frame.width + 6, followingButton.frame.origin.y, 0.6, 45)
        contentView.addSubview(line2)
        contentView.addSubview(line3)
        cellHeight = likeView.frame.origin.y + likeView.frame.height + 7
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}
