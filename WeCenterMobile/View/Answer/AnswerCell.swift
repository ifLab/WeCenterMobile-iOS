//
//  AnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/29.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerCell: UITableViewCell {
    
    var answer: Answer?

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: MSRMultilineLabel!
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var agreementCountLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        agreementCountLabel.layer.borderColor = UIColor.msr_materialGray300().CGColor
        agreementCountLabel.layer.borderWidth = 0.5
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        answerButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#answer: Answer, updateImage: Bool) {
        self.answer = answer
        userNameLabel.text = answer.user?.name ?? "匿名用户"
        answerBodyLabel.text = answer.body?.wc_plainString
        agreementCountLabel.text = "\(answer.agreementCount ?? 0)"
        userButton.msr_userInfo = answer.user
        answerButton.msr_userInfo = answer
        if updateImage {
            userAvatarView.wc_updateWithUser(answer.user)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
