//
//  QuestionPublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class QuestionPublishmentActionCell: ActionCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    
    override func update(#action: Action) {
        super.update(action: action)
        let action = action as QuestionPublishmentAction
        questionTitleLabel.text = action.question.title
        questionTitleLabel.preferredMaxLayoutWidth = questionTitleLabel.bounds.width
    }
    
}