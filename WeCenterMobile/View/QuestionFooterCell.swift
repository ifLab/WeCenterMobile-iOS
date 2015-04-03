//
//  QuestionFooterCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionFooterCell: UITableViewCell {
    
    @IBOutlet weak var viewCountImageView: UIImageView!
    @IBOutlet weak var focusCountImageView: UIImageView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var focusCountLabel: UILabel!
    @IBOutlet weak var focusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewCountImageView.image = viewCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusCountImageView.image = focusCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusButton.msr_setBackgroundImageWithColor(focusButton.backgroundColor!)
        focusButton.backgroundColor = UIColor.clearColor()
    }
    
    func update(#question: Question) {
        viewCountLabel.text = "\(question.viewCount ?? 0)"
        focusCountLabel.text = "\(question.focusCount ?? 0)"
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
