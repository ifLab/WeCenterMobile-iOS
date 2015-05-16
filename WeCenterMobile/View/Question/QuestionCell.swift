//
//  QuestionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/28.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionBodyLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var containerView: UIView!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        questionButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#question: Question, updateImage: Bool) {
        questionTitleLabel.text = question.title
        questionBodyLabel.text = question.body!.wc_plainString
        userNameLabel.text = question.user?.name ?? "匿名用户"
        dateLabel.text = dateFormatter.stringFromDate(question.date!)
        if updateImage {
            userAvatarView.wc_updateWithUser(question.user)
        }
        userButton.msr_userInfo = question.user
        questionButton.msr_userInfo = question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
