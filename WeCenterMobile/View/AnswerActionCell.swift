//
//  AnswerActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/28.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class AnswerActionCell: ActionCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var agreementCountLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
    }
    
    override func update(#action: Action) {
        super.update(action: action)
        let action = action as! AnswerAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        questionTitleLabel.text = action.answer.question!.title!
        agreementCountLabel.text = "\(action.answer.agreementCount!)"
        answerBodyLabel.text = action.answer.body!
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
