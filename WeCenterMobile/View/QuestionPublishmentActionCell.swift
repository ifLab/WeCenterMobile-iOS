//
//  QuestionPublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class QuestionPublishmentActionCell: ActionCell {
    
    @IBOutlet weak var questionTitleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionTitleButton.titleLabel!.preferredMaxLayoutWidth = questionTitleButton.bounds.width
        questionTitleButton.titleLabel!.numberOfLines = 0
    }
    
    override func update(#action: Action) {
        super.update(action: action)
        let action = action as QuestionPublishmentAction
        questionTitleButton.setTitle(action.question.title! + action.question.title!, forState: .Normal)
        questionTitleButton.msr_userInfo = action.question
    }
    
}