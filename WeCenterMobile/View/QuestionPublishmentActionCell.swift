//
//  QuestionPublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class QuestionPublishmentActionCell: ActionCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionTitleButton: UIButton!
    
    override func update(#action: Action) {
        super.update(action: action)
        let action = action as! QuestionPublishmentAction
        questionTitleLabel.text = action.question.title
        questionTitleButton.msr_userInfo = action.question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
