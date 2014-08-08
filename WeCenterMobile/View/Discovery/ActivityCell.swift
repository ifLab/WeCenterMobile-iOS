//
//  ActivityCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/3.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {
    
    private let innerView = InnerView()
    let titleView = UIView()
    let titleLabel = UILabel()
    let answerView = UIView()
    let answerUserAvatarView = UIImageView()
    let answerUserNameLabel = UILabel()
    let answerContentLabel = UILabel()
    
    init(activity: Activity, width: CGFloat, autoLoadingAvatar: Bool, reuseIdentifier: String!) {
        let maxTitleLabelSize = CGSize(width: width - 40, height: CGFloat.max)
        titleLabel.text = activity.title
        titleLabel.lineBreakMode = .ByCharWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleLabel.frame = CGRect(x: 10, y: 20, width: width - 40, height: titleLabel.sizeThatFits(maxTitleLabelSize).height)
        titleView.frame = CGRect(x: 0, y: 0, width: width - 20, height: titleLabel.frame.size.height + 40)
        
        if let questionActivity = activity as? QuestionActivity {
            if questionActivity.answerUser != nil {
                answerUserAvatarView.frame = CGRect(x: 10, y: 15, width: 40, height: 40)
                answerUserAvatarView.layer.masksToBounds = true
                answerUserAvatarView.layer.cornerRadius = answerUserAvatarView.frame.width / 2
                answerUserAvatarView.layer.borderWidth = 0.5
                answerUserAvatarView.layer.borderColor = UIColor.lightGrayColor().CGColor
                if autoLoadingAvatar {
                    answerUserAvatarView.setImageWithURL(NSURL(string: questionActivity.answerUser!.avatarURL!.stringByReplacingOccurrencesOfString("min", withString: "max", options: .BackwardsSearch, range: nil))) // Needs modifing
                }
                answerUserNameLabel.font = UIFont.systemFontOfSize(15)
                answerUserNameLabel.text = questionActivity.answerUser!.name
                answerUserNameLabel.frame.size = answerUserNameLabel.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max))
                answerUserNameLabel.frame.origin = CGPoint(x: answerUserAvatarView.frame.origin.x + answerUserAvatarView.frame.width + 10, y: answerUserAvatarView.frame.origin.y)
                answerContentLabel.font = UIFont.systemFontOfSize(14)
                answerContentLabel.textColor = UIColor.grayColor()
                answerContentLabel.lineBreakMode = .ByCharWrapping
                answerContentLabel.numberOfLines = 4
                answerContentLabel.text = questionActivity.answerContent
                answerContentLabel.frame.size = answerContentLabel.sizeThatFits(CGSize(width: width - 20 - answerUserNameLabel.frame.origin.x - 10, height: CGFloat.max))
                answerContentLabel.frame.origin = CGPoint(x: answerUserNameLabel.frame.origin.x, y: answerUserNameLabel.frame.origin.y + answerUserNameLabel.frame.height + 5)
                answerView.frame = CGRect(x: 0, y: titleView.frame.origin.x + titleView.frame.height, width: width - 20, height: max(answerUserAvatarView.frame.origin.y + answerUserAvatarView.frame.height, answerContentLabel.frame.origin.y + answerContentLabel.frame.height) + 10)
            }
            innerView.frame = CGRect(x: 10, y: 10, width: width - 20, height: titleView.frame.height + answerView.frame.height)
        } else if let ariticalActivity = activity as? ArticalActivity {
            innerView.frame = CGRect(x: 10, y: 10, width: width - 20, height: titleView.frame.height)
        }
        innerView.layer.borderWidth = 0.5
        innerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: width, height: innerView.frame.size.height + 10)
        contentView.addSubview(innerView)
        innerView.addSubview(titleView)
        innerView.addSubview(answerView)
        titleView.addSubview(titleLabel)
        answerView.addSubview(answerUserAvatarView)
        answerView.addSubview(answerUserNameLabel)
        answerView.addSubview(answerContentLabel)
        innerView.backgroundColor = UIColor.whiteColor()
        backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    private class InnerView: UIView {
        
        override init() {
            super.init()
        }
        
        required init(coder aDecoder: NSCoder!) {
            super.init(coder: aDecoder)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        override func drawRect(rect: CGRect) {
            let cell = superview!.superview as ActivityCell
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: cell.titleView.frame.origin.x + 10, y: cell.titleView.frame.height + cell.titleView.frame.origin.y))
            path.addLineToPoint(CGPoint(x: cell.titleView.frame.origin.x + cell.titleView.frame.size.width - 10, y: cell.titleView.frame.height + cell.titleView.frame.origin.y))
            UIColor(white: 0, alpha: 0.1).set()
            path.stroke()
        }
        
    }
    
}
