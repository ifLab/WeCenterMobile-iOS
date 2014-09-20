//
//  ActivityCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/3.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {
    
    private let innerView = UIView()
    let titleButton = BFPaperButton(raised: false)
    let titleLabel = UILabel()
    let answerView = UIView()
    let answerUserAvatarButton = UIButton()
    let answerUserNameLabel = UILabel()
    let answerContentLabel = UILabel()
    
    init(activity: Activity, width: CGFloat, autoLoadingAvatar: Bool, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        let maxTitleLabelSize = CGSize(width: width - 20, height: CGFloat.max)
        titleLabel.text = activity.title
        titleLabel.lineBreakMode = .ByCharWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleLabel.frame = CGRect(x: 10, y: 20, width: width - 20, height: titleLabel.sizeThatFits(maxTitleLabelSize).height)
        titleButton.frame = CGRect(x: 0, y: 0, width: width, height: titleLabel.frame.size.height + 40)
        titleButton.usesSmartColor = false
        titleButton.backgroundColor = UIColor.materialGray300()
        answerView.frame = CGRectZero
        if let questionActivity = activity as? QuestionActivity {
            if questionActivity.answerUser != nil {
                titleButton.msr_userInfo = (questionActivity.id.stringByReplacingOccurrencesOfString("question_id_", withString: "", options: nil, range: questionActivity.id.startIndex..<questionActivity.id.endIndex) as NSString).integerValue
                answerUserAvatarButton.frame = CGRect(x: 10, y: 15, width: 40, height: 40)
                answerUserAvatarButton.imageView!.layer.masksToBounds = true
                answerUserAvatarButton.imageView!.layer.cornerRadius = answerUserAvatarButton.frame.width / 2
                answerUserAvatarButton.imageView!.layer.borderWidth = 0.5
                answerUserAvatarButton.imageView!.layer.borderColor = UIColor.lightGrayColor().CGColor
                answerUserAvatarButton.msr_userInfo = questionActivity.answerUserID!
                if autoLoadingAvatar && questionActivity.answerUser!.avatarURL != nil {
                    answerUserAvatarButton.setImageForState(.Normal, withURL: NSURL(string: questionActivity.answerUser!.avatarURL!.stringByReplacingOccurrencesOfString("min", withString: "max", options: .BackwardsSearch, range: nil))) // Needs modifing
                }
                answerUserNameLabel.font = UIFont.systemFontOfSize(15)
                answerUserNameLabel.text = questionActivity.answerUser!.name
                answerUserNameLabel.frame.size = answerUserNameLabel.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max))
                answerUserNameLabel.frame.origin = CGPoint(x: answerUserAvatarButton.frame.origin.x + answerUserAvatarButton.frame.width + 10, y: answerUserAvatarButton.frame.origin.y)
                answerContentLabel.font = UIFont.systemFontOfSize(14)
                answerContentLabel.textColor = UIColor.grayColor()
                answerContentLabel.lineBreakMode = .ByCharWrapping
                answerContentLabel.numberOfLines = 4
                answerContentLabel.text = questionActivity.answerContent
                answerContentLabel.frame.size = answerContentLabel.sizeThatFits(CGSize(width: width - answerUserNameLabel.frame.origin.x - 10, height: CGFloat.max))
                answerContentLabel.frame.origin = CGPoint(x: answerUserNameLabel.frame.origin.x, y: answerUserNameLabel.frame.origin.y + answerUserNameLabel.frame.height + 5)
                answerView.frame = CGRect(x: 0, y: titleButton.frame.origin.x + titleButton.frame.height, width: width, height: max(answerUserAvatarButton.frame.origin.y + answerUserAvatarButton.frame.height, answerContentLabel.frame.origin.y + answerContentLabel.frame.height) + 10)
                answerView.backgroundColor = UIColor.materialGray100()
            }
            innerView.frame = CGRect(x: 0, y: 10, width: width, height: titleButton.frame.height + answerView.frame.height)
        } else if let ariticalActivity = activity as? ArticalActivity {
            innerView.frame = CGRect(x: 0, y: 10, width: width - 20, height: titleButton.frame.height)
        }
        frame = CGRect(x: 0, y: 0, width: width, height: innerView.frame.size.height + 10)
        contentView.addSubview(innerView)
        innerView.addSubview(titleButton)
        innerView.addSubview(answerView)
        titleButton.addSubview(titleLabel)
        answerView.addSubview(answerUserAvatarButton)
        answerView.addSubview(answerUserNameLabel)
        answerView.addSubview(answerContentLabel)
        innerView.backgroundColor = UIColor.whiteColor()
        backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
