//
//  QuestionFocusingActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class QuestionFocusingActionCell: ActionCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
        questionButton.msr_setBackgroundImageWithColor(questionButton.backgroundColor!)
        questionButton.backgroundColor = UIColor.clearColor()
    }
    
    override func update(#action: Action, updateImage: Bool) {
        super.update(action: action, updateImage: updateImage)
        let action = action as! QuestionFocusingAction
        if updateImage {
            userAvatarView.wc_updateWithUser(action.user)
        }
        userNameLabel.text = action.user?.name ?? "匿名用户"
        questionTitleLabel.text = action.question.title
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
