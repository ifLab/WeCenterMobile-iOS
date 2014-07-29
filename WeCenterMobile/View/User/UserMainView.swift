//
//  UserMaimView.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserMainView: UIView {
    var photo:UIImageView
    var name:UILabel
    var topic:UIButton
    var iCare:UIButton
    var careMe:UIButton
    var praise:UIImageView
    var like:UIImageView
    var prestige:UIImageView
    var bodyList:UITableView
    var topicNum:UILabel?
    var iCareNum:UILabel?
    var careMeNum:UILabel?
    var prestigeNum:UILabel?
    var praiseNum:UILabel?
    var likeNum:UILabel?
    var introduction:UILabel?
    var shortIntroduction:UILabel?
    
    init(frame: CGRect, user: User) {
        photo = UIImageView()
        name = UILabel()
        topic = UIButton()
        iCare = UIButton()
        careMe = UIButton()
        praise = UIImageView()
        like = UIImageView()
        bodyList = UITableView()
        prestige = UIImageView()
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        var bodyView: UIView = UIView(frame: frame)
        
        photo.backgroundColor = UIColor.grayColor()
        photo.frame = CGRectMake(10, 15, 76, 76)
        bodyView.addSubview(photo)
        
        name.text = user.name
        name.textColor = UIColor.blackColor()
        name.frame = CGRectMake(96, 15, 200, 20)
        name.font = UIFont.systemFontOfSize(16)
        name.sizeToFit()
        bodyView.addSubview(name)
        
//        shortIntroduction = UILabel(frame: CGRectMake(name.frame.origin.x + name.frame.width , name.frame.origin.y, 300 - name.frame.origin.x - name.frame.width - 5, 20))
//        shortIntroduction!.textColor = UIColor.blackColor()
////        user.birthday.
//        shortIntroduction!.text = ", " + user.birthday.description
//        shortIntroduction!.font = UIFont.systemFontOfSize(16)
//        bodyView.addSubview(shortIntroduction)
        
        topic.setTitle("我的话题", forState: .Normal)
        topic.titleLabel.font = UIFont.systemFontOfSize(10)
        topic.setTitleColor(UIColor.grayColor(), forState: .Normal)
        topic.frame = CGRectMake(100, 45, 65, 65)
        topic.backgroundColor = UIColor.whiteColor()
        
        topicNum = UILabel(frame: CGRectMake(12, 10, 56, 13))
        topicNum!.font = UIFont.systemFontOfSize(13)
        topicNum!.textColor = UIColor.darkTextColor()
        topicNum!.text = "\(0))"
        topic.addSubview(topicNum)
        bodyView.addSubview(topic)
        
        iCare.frame = CGRectMake(170, 45, 65, 65)
        iCare.setTitle("我关注的人", forState: UIControlState.Normal)
        iCare.setTitleColor(UIColor.grayColor(), forState: .Normal)
        iCare.titleLabel.font = UIFont.systemFontOfSize(10)
        iCare.backgroundColor = UIColor.whiteColor()
        
        iCareNum = UILabel(frame: CGRectMake(7, 10, 60, 13))
        iCareNum!.font = UIFont.systemFontOfSize(13)
        iCareNum!.textColor = UIColor.darkTextColor()
        iCareNum!.text = "\(0)"
        iCare.addSubview(iCareNum)
        bodyView.addSubview(iCare)
        
        careMe.frame = CGRectMake(240, 45, 65, 65)
        careMe.setTitleColor(UIColor.grayColor(), forState:  .Normal)
        careMe.setTitle("关注我的人", forState: .Normal)
        careMe.titleLabel.font = UIFont.systemFontOfSize(10)
        careMe.backgroundColor = UIColor.whiteColor()
        
        careMeNum = UILabel(frame: CGRectMake(8, 10, 60, 13))
        careMeNum!.font = UIFont.systemFontOfSize(13)
        careMeNum!.textColor = UIColor.darkTextColor()
        careMeNum!.text = "\(0)"
        careMe.addSubview(careMeNum)
        bodyView.addSubview(careMe)
        
        introduction = UILabel()
        introduction!.frame.origin = CGPoint(x: photo.frame.origin.x, y: photo.frame.origin.y + photo.frame.height + 5)
        introduction!.font = UIFont.systemFontOfSize(13)
        introduction!.textColor = UIColor.darkTextColor()
        introduction!.text = "\(0)"
        introduction!.frame = CGRectMake(  photo.frame.origin.x, photo.frame.origin.y + photo.frame.height + 5, 300, 20)
        introduction!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        introduction!.numberOfLines = 0;
        introduction!.sizeToFit()
        bodyView.addSubview(introduction)
        
        let line4 = UIView(frame: CGRectMake(0, introduction!.frame.origin.y + introduction!.frame.height + 5, 320, 1))
        line4.backgroundColor = UIColor.grayColor()
        bodyView.addSubview(line4)
        
        prestige = UIImageView(frame: CGRectMake(10, line4.frame.origin.y + 9, 18, 18))
        prestige.backgroundColor = UIColor.grayColor()
        bodyView.addSubview(prestige)
        
        prestigeNum = UILabel(frame: CGRectMake(prestige.frame.origin.x + 21, line4.frame.origin.y + 9, 30, 18))
        prestigeNum!.font = UIFont.systemFontOfSize(13)
        prestigeNum!.textColor = UIColor.grayColor()
        prestigeNum!.text = "\(0)"
        prestigeNum!.sizeToFit()
        bodyView.addSubview(prestigeNum)
        
        praise = UIImageView(frame: CGRectMake(prestigeNum!.frame.origin.x + prestigeNum!.frame.width + 3, line4.frame.origin.y + 9, 18, 18))
        praise.backgroundColor = UIColor.grayColor()
        bodyView.addSubview(praise)
        
        praiseNum = UILabel(frame: CGRectMake(praise.frame.origin.x + praise.frame.width + 3 , line4.frame.origin.y + 9, 30, 18))
        praiseNum!.font = UIFont.systemFontOfSize(13)
        praiseNum!.textColor = UIColor.grayColor()
        praiseNum!.text = "\(0)"
        praiseNum!.sizeToFit()
        bodyView.addSubview(praiseNum)
        
        like = UIImageView(frame: CGRectMake(praiseNum!.frame.origin.x + praiseNum!.frame.width + 3, line4.frame.origin.y + 9, 18, 18))
        like.backgroundColor = UIColor.grayColor()
        bodyView.addSubview(like)
        
        likeNum = UILabel(frame: CGRectMake(like.frame.origin.x + 21, line4.frame.origin.y + 9, 30, 18))
        likeNum!.font = UIFont.systemFontOfSize(13)
        likeNum!.textColor = UIColor.grayColor()
        likeNum!.text = "\(0)"
        likeNum!.sizeToFit()
        bodyView.addSubview(likeNum)
        
        let line1 = UIView(frame: CGRectMake(96, 38, 200, 1))
        line1.backgroundColor = UIColor.grayColor()
        bodyView.addSubview(line1)
        let line2 = UIView()
        line2.backgroundColor = UIColor.grayColor()
        let line3 = UIView()
        line3.backgroundColor = UIColor.grayColor()
        line2.frame = CGRectMake(careMe.frame.origin.x - 3, careMe.frame.origin.y, 1, 45)
        line3.frame = CGRectMake(iCare.frame.origin.x - 3, iCare.frame.origin.y, 1, 45)
        bodyView.addSubview(line2)
        bodyView.addSubview(line3)
        
        self.addSubview(bodyView)
    }
}
