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
    
    override func update(#object: FeaturedObject, updateImage: Bool) {
        super.update(object: object, updateImage: updateImage)
        if !objectChanged {
            return
        }
        let object = object as! FeaturedQuestionAnswer
        if updateImage {
            userAvatarView.wc_updateWithUser(object.question.user)
        }
        userNameLabel.text = object.question.user?.name ?? "匿名用户"
        questionTitleLabel.text = object.question.title
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
