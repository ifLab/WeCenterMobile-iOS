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
    @IBOutlet weak var focusActivityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewCountImageView.image = viewCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusCountImageView.image = focusCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusButton.msr_setBackgroundImageWithColor(focusButton.backgroundColor!)
        focusButton.backgroundColor = UIColor.clearColor()
        focusButton.setTitle(nil, forState: .Normal)
    }
    
    func update(#question: Question) {
        viewCountLabel.text = "\(question.viewCount ?? 0)"
        focusCountLabel.text = "\(question.focusCount ?? 0)"
        if let focusing = question.focusing {
            focusButton.msr_setBackgroundImageWithColor(focusing ? UIColor.msr_materialBrown800() : UIColor.msr_materialBrown600())
            focusButton.setTitle(focusing ? "已关注" : "关注", forState: .Normal)
            focusActivityIndicatorView.stopAnimating()
        } else {
            focusButton.setTitle(nil, forState: .Normal)
            focusActivityIndicatorView.startAnimating()
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
