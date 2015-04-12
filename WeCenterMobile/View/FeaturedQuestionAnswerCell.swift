//
//  FeaturedQuestionAnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedQuestionAnswerCell: FeaturedObjectCell {
    
    @IBOutlet weak var questionUserAvatarView: UIImageView!
    @IBOutlet weak var questionUserNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerUserAvatarView: UIImageView!
    @IBOutlet weak var answerBodyLabel: UILabel!
    @IBOutlet weak var answerUserNameLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var questionTagLabel: UILabel!
    @IBOutlet weak var answerTagLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerUserAvatarView.layer.masksToBounds = true
        answerUserAvatarView.layer.cornerRadius = answerUserAvatarView.bounds.width / 2
        questionUserAvatarView.layer.masksToBounds = true
        questionUserAvatarView.layer.cornerRadius = questionUserAvatarView.bounds.width / 2
        questionTagLabel.layer.masksToBounds = false
        questionTagLabel.layer.shadowColor = UIColor.msr_materialBrown900().CGColor
        questionTagLabel.layer.shadowPath = UIBezierPath(rect: questionTagLabel.bounds).CGPath
        questionTagLabel.layer.shadowOpacity = 1
        questionTagLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        questionTagLabel.layer.shadowRadius = 1
        answerTagLabel.layer.masksToBounds = false
        answerTagLabel.layer.shadowColor = UIColor.msr_materialBrown900().CGColor
        answerTagLabel.layer.shadowPath = UIBezierPath(rect: answerTagLabel.bounds).CGPath
        answerTagLabel.layer.shadowOpacity = 1
        answerTagLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        answerTagLabel.layer.shadowRadius = 1
        questionButton.msr_setBackgroundImageWithColor(questionButton.backgroundColor!)
        questionButton.backgroundColor = UIColor.clearColor()
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
        answerBodyLabel.text = answer?.body ?? ""
        questionButton.msr_userInfo = question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
