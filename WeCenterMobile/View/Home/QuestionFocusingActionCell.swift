//
//  QuestionFocusingActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionFocusingActionCell: ActionCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        questionButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        separatorWidthConstraint.constant = 0.5
    }
    
    override func update(#action: Action, updateImage: Bool) {
        super.update(action: action, updateImage: updateImage)
        let action = action as! QuestionFocusingAction
        if updateImage {
            userAvatarView.wc_updateWithUser(action.user)
        }
        userNameLabel.text = action.user?.name ?? "匿名用户"
        questionTitleLabel.text = action.question!.title
        userButton.msr_userInfo = action.user
        questionButton.msr_userInfo = action.question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
