//
//  FeaturedQuestionAnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedQuestionAnswerCell: FeaturedObjectCell {
    
    @IBOutlet weak var questionUserAvatarView: MSRRoundedImageView!
    @IBOutlet weak var questionUserNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerUserAvatarView: MSRRoundedImageView!
    @IBOutlet weak var answerBodyLabel: UILabel!
    @IBOutlet weak var answerUserNameLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var questionTagLabel: UILabel!
    @IBOutlet weak var answerTagLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
        answerButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    override func update(#object: FeaturedObject, updateImage: Bool) {
        super.update(object: object, updateImage: updateImage)
        if !objectChanged {
            return
        }
        let object = object as! FeaturedQuestionAnswer
        let question = object.question
        let answer = object.answers.first
        if updateImage {
            questionUserAvatarView.wc_updateWithUser(question.user)
            answerUserAvatarView.wc_updateWithUser(answer?.user)
        }
        questionUserNameLabel.text = question.user?.name
        questionTitleLabel.text = question.title
        answerUserNameLabel.text = answer?.user?.name ?? "匿名用户"
        answerBodyLabel.text = answer?.body!.wc_plainString
        questionButton.msr_userInfo = question
        answerButton.msr_userInfo = answer
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
