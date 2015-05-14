//
//  FeaturedQuestionAnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedQuestionAnswerCell: UITableViewCell {
    
    @IBOutlet weak var questionUserAvatarView: MSRRoundedImageView!
    @IBOutlet weak var questionUserNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerUserAvatarView: MSRRoundedImageView?
    @IBOutlet weak var answerBodyLabel: UILabel?
    @IBOutlet weak var answerUserNameLabel: UILabel?
    @IBOutlet weak var questionBadgeLabel: UILabel!
    @IBOutlet weak var answerBadgeLabel: UILabel?
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answerButton: UIButton?
    @IBOutlet weak var questionUserButton: UIButton!
    @IBOutlet weak var answerUserButton: UIButton?
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        questionBadgeLabel.layer.borderColor = UIColor.msr_materialGray300().CGColor
        questionBadgeLabel.layer.borderWidth = 0.5
        answerBadgeLabel?.layer.borderColor = UIColor.msr_materialGray300().CGColor
        answerBadgeLabel?.layer.borderWidth = 0.5
        questionButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        questionUserButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        answerButton?.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        answerUserButton?.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#object: FeaturedObject, updateImage: Bool) {
        let object = object as! FeaturedQuestionAnswer
        let question = object.question!
        let answer = object.answers.first
        if updateImage {
            questionUserAvatarView.wc_updateWithUser(question.user)
            answerUserAvatarView?.wc_updateWithUser(answer?.user)
        }
        questionUserNameLabel.text = question.user?.name
        questionTitleLabel.text = question.title
        answerUserNameLabel?.text = answer?.user?.name ?? "匿名用户"
        answerBodyLabel?.text = answer?.body!.wc_plainString
        questionButton.msr_userInfo = question
        answerButton?.msr_userInfo = answer
        questionUserButton.msr_userInfo = question.user
        answerUserButton?.msr_userInfo = answer?.user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
