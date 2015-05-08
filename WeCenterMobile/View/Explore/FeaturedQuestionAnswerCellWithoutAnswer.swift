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
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionTagLabel: UIView!
    @IBOutlet weak var questionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    override func update(#object: FeaturedObject, updateImage: Bool) {
        super.update(object: object, updateImage: updateImage)
        if !objectChanged {
            return
        }
        let object = object as! FeaturedQuestionAnswer
        if updateImage {
            userAvatarView.wc_updateWithUser(object.question!.user)
        }
        userNameLabel.text = object.question!.user?.name ?? "匿名用户"
        questionTitleLabel.text = object.question!.title
        questionButton.msr_userInfo = object.question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
