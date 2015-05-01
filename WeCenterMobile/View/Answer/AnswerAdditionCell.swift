//
//  AnswerAdditionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/29.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerAdditionCell: UITableViewCell {
    
    @IBOutlet weak var answerAdditionImageView: UIImageView!
    @IBOutlet weak var answerAdditionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerAdditionImageView.msr_imageRenderingMode = .AlwaysTemplate
        answerAdditionButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }

}
