//
//  FeaturedQuestionAnswerCellWithoutAnswer.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/15.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedQuestionAnswerCellWithoutAnswer: FeaturedObjectCell {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionTagLabel: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
        questionTagLabel.layer.masksToBounds = false
        questionTagLabel.layer.shadowColor = UIColor.msr_materialBrown900().CGColor
        questionTagLabel.layer.shadowPath = UIBezierPath(rect: questionTagLabel.bounds).CGPath
        questionTagLabel.layer.shadowOpacity = 1
        questionTagLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        questionTagLabel.layer.shadowRadius = 1
    }
    
    override func update(#object: FeaturedObject) {
        super.update(object: object)
        if !objectChanged {
            return
        }
        let object = object as! FeaturedQuestionAnswer
        let question = object.question
        let user = question.user
        let userID = user?.id.integerValue
        userAvatarView.image = UIImage(named: "DefaultAvatar")
        userAvatarView.msr_userInfo = user?.avatarURL
        if user?.avatarURL != nil {
            user?.fetchAvatar(
                success: {
                    [weak self] in
                    if (self?.userAvatarView.msr_userInfo as? String) == user?.avatarURL {
                        self?.userAvatarView.image = user?.avatar
                    }
                    return
                },
                failure: nil)
        }
        userNameLabel.text = user?.name ?? "匿名用户"
        questionTitleLabel.text = question.title
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
