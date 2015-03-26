//
//  QuestionDetailCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionDetailCell: QuestionDetailBaseCell {
    
    var question: Question? {
        return super.object as? Question
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionBodyLabel: DTAttributedLabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var focusCountLabel: UILabel!
    @IBOutlet weak var viewCountImageView: UIImageView!
    @IBOutlet weak var focusCountImageView: UIImageView!
    @IBOutlet weak var focusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewCountImageView.image = viewCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusCountImageView.image = focusCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusButton.setBackgroundImage(UIImage.msr_rectangleWithColor(focusButton.backgroundColor!, size: CGSize(width: 1, height: 1)), forState: .Normal)
        focusButton.backgroundColor = UIColor.clearColor()
        questionBodyLabel.numberOfLines = 0
//        questionBodyLabel.layoutFrameHeightIsConstrainedByBounds = true
    }
    
    override func update(#object: AnyObject?) {
        super.update(object: object)
        if let question = question {
            userNameLabel.text = question.user?.name ?? "匿名用户"
            userSignatureLabel.text = question.user?.signature ?? ""
            questionTitleLabel.text = question.title
            var HTMLString = ""
            if question.body != nil {
                HTMLString = "<p style='padding: 10px'>\(question.body ?? String())</p>"
            }
            let attributedString = NSAttributedString(
                HTMLData: HTMLString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
                options: [
                    NSTextSizeMultiplierDocumentOption: 1,
                    DTDefaultFontName: UIFont.systemFontOfSize(14).fontName,
                    DTDefaultFontSize: 14,
                    DTDefaultTextColor: UIColor.lightTextColor(),
                    DTDefaultLinkColor: UIColor.msr_materialBlue500(),
                    DTDefaultLinkHighlightColor: UIColor.msr_materialPurple300(),
                    DTDefaultLineHeightMultiplier: 1.5,
                    DTDefaultLinkDecoration: false],
                documentAttributes: nil)
            if questionBodyLabel.attributedString?.isEqualToAttributedString(attributedString) ?? true {
                questionBodyLabel.attributedString = attributedString
                questionBodyLabel.sizeToFit()
            }
            viewCountLabel.text = "\(question.viewCount ?? 0)"
            focusCountLabel.text = "\(question.focusCount ?? 0)"
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
