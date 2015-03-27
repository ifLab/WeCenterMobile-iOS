//
//  QuestionDetailCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionDetailCell: QuestionDetailBaseCell, NSLayoutManagerDelegate {
    
    var question: Question? {
        return super.object as? Question
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionBodyView: UITextView!
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
        questionBodyView.layoutManager.delegate = self
    }
    
    override func update(#object: AnyObject?) {
        super.update(object: object)
        if let question = question {
            userNameLabel.text = question.user?.name ?? "匿名用户"
            userSignatureLabel.text = question.user?.signature ?? ""
            questionTitleLabel.text = question.title
//            let attributedString = NSAttributedString(
//                HTMLData: (question.body ?? "").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
//                options: [
//                    NSTextSizeMultiplierDocumentOption: 1,
//                    DTDefaultFontName: UIFont.systemFontOfSize(14).fontName,
//                    DTDefaultFontSize: 14,
//                    DTDefaultTextColor: UIColor.lightTextColor(),
//                    DTDefaultLinkColor: UIColor.msr_materialBlue500(),
//                    DTDefaultLinkHighlightColor: UIColor.msr_materialPurple300(),
//                    DTDefaultLineHeightMultiplier: 1.5,
//                    DTDefaultLinkDecoration: false],
//                documentAttributes: nil)
            var dict: NSDictionary?
            var begin = NSDate().timeIntervalSince1970
            let attributedString = NSMutableAttributedString(
                data: (question.body ?? "").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
                options: [
                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                    NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
                    NSBackgroundColorDocumentAttribute: UIColor.clearColor()],
                documentAttributes: &dict,
                error: nil)!
//            attributedString.beginEditing()
//            attributedString.setAttributes([
//                NSFontAttributeName: UIFont.systemFontOfSize(14),
//                NSForegroundColorAttributeName: UIColor.lightTextColor()],
//                range: NSRange(location: 0, length: attributedString.length))
//            attributedString.endEditing()
            attributedString.enumerateAttributesInRange(NSRange(location: 0, length: attributedString.length),
                options: NSAttributedStringEnumerationOptions.allZeros) {
                    [weak self] values, range, stop in
                    if let self_ = self {
                        if let attachment = values[NSAttachmentAttributeName] as? NSTextAttachment {
                            println(values)
                            println(attachment)
                            println(attachment.contents)
                            println(attachment.fileType)
                            println(attachment.fileWrapper?.fileAttributes)
                            println()
                            if let image = attachment.image {
                                var size = image.size
                                if size.width > self_.questionBodyView.bounds.width {
                                    let scale = self_.questionBodyView.bounds.width / size.width
                                    attachment.image = UIImage(CGImage: image.CGImage, scale: scale, orientation: .Up)
                                }
                                
                            }
                            
                        } else {
                        }
                    }
            }
            questionBodyView.attributedText = attributedString
            viewCountLabel.text = "\(question.viewCount ?? 0)"
            focusCountLabel.text = "\(question.focusCount ?? 0)"
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func layoutManager(layoutManager: NSLayoutManager, boundingBoxForControlGlyphAtIndex glyphIndex: Int, forTextContainer textContainer: NSTextContainer, proposedLineFragment proposedRect: CGRect, glyphPosition: CGPoint, characterIndex charIndex: Int) -> CGRect {
        println(proposedRect)
        return proposedRect
    }
    
}
