//
//  AnswerActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/28.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerActionCell: ActionCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var agreementCountLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
        answerButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    override func update(#action: Action, updateImage: Bool) {
        super.update(action: action, updateImage: updateImage)
        let action = action as! AnswerAction
        if updateImage {
            userAvatarView.wc_updateWithUser(action.user)
        }
        userNameLabel.text = action.user?.name ?? "匿名用户"
        questionTitleLabel.text = action.answer!.question!.title!
        agreementCountLabel.text = "\(action.answer!.agreementCount!)"
        answerBodyLabel.text = action.answer!.body!.wc_plainString
        questionButton.msr_userInfo = action.answer!.question
        answerButton.msr_userInfo = action.answer
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
