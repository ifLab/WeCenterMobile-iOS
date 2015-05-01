//
//  QuestionTitleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionTitleCell: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    
    func update(#question: Question) {
        questionTitleLabel.text = question.title ?? "加载中"
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
