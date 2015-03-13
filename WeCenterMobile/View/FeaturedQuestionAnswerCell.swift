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
    
    override func update(#object: FeaturedObject) {
        let object = object as! FeaturedQuestionAnswer
        let question = object.question
        let answer = object.answers.first
        if let urlString = question.user?.avatarURL {
            questionUserAvatarView.setImageWithURL(NSURL(string: urlString))
        }
        questionUserNameLabel.text = question.user?.name
        questionTitleLabel.text = question.title
        if let urlString = answer?.user?.avatarURL {
            answerUserAvatarView.setImageWithURL(NSURL(string: urlString))
        }
        answerUserNameLabel.text = answer?.user?.name ?? "匿名用户"
        answerBodyLabel.text = answer?.body ?? ""
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
