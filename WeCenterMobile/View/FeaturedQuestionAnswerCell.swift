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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        innerView.layer.masksToBounds = true
        innerView.layer.cornerRadius = 3
        answerUserAvatarView.layer.masksToBounds = true
        answerUserAvatarView.layer.cornerRadius = answerUserAvatarView.bounds.width / 2
        questionUserAvatarView.layer.masksToBounds = true
        questionUserAvatarView.layer.cornerRadius = questionUserAvatarView.bounds.width / 2
    }
    
    override func update(#object: FeaturedObject) {
        let object = object as! FeaturedQuestionAnswer
        let question = object.question
        let answer = object.answers.first
        questionUserAvatarView.image = UIImage(named: "DefaultAvatar")
        questionUserAvatarView.msr_userInfo = question.user
        if let urlString = question.user?.avatarURL {
            let userID = question.user?.id.integerValue
            question.user!.fetchAvatar(
                success: {
                    [weak self] in
                    if let user = self?.questionUserAvatarView.msr_userInfo as? User {
                        if user.id == userID {
                            self?.questionUserAvatarView.image = user.avatar
                        }
                    }
                },
                failure: nil)
        }
        questionUserNameLabel.text = question.user?.name
        questionTitleLabel.text = question.title
        answerUserAvatarView.image = UIImage(named: "DefaultAvatar")
        answerUserAvatarView.msr_userInfo = answer?.user
        if let urlString = answer?.user?.avatarURL {
            let userID = answer!.user!.id.integerValue
            answer!.user!.fetchAvatar(
                success: {
                    [weak self] in
                    if let user = self?.answerUserAvatarView.msr_userInfo as? User {
                        if user.id == userID {
                            self?.answerUserAvatarView.image = user.avatar
                        }
                    }
                },
                failure: nil)
        }
        answerUserNameLabel.text = answer?.user?.name ?? "匿名用户"
        answerBodyLabel.text = answer?.body ?? ""
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
