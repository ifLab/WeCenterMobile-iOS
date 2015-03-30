//
//  QuestionDetailCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionDetailCell: UITableViewCell, NSLayoutManagerDelegate {
    
    var question: Question?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionBodyView: UITextView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var focusCountLabel: UILabel!
    @IBOutlet weak var viewCountImageView: UIImageView!
    @IBOutlet weak var focusCountImageView: UIImageView!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var userAvatarView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewCountImageView.image = viewCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusCountImageView.image = focusCountImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        focusButton.msr_setBackgroundImageWithColor(focusButton.backgroundColor!)
        focusButton.backgroundColor = UIColor.clearColor()
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
    }
    
    func update(#object: Question?) {
        question = object
        if let question = question {
            userNameLabel.text = question.user?.name ?? "匿名用户"
            userSignatureLabel.text = question.user?.signature ?? ""
            questionTitleLabel.text = question.title
            userAvatarView.image = UIImage(named: "DefaultAvatar")
            userAvatarView.msr_userInfo = question.user
            if let avatar = question.user?.avatar {
                userAvatarView.image = avatar
            }
            var user = question.user
            if user?.avatarURL != nil {
                user?.fetchAvatar(
                    success: {
                        [weak self] in
                        if let user_ = self?.userAvatarView.msr_userInfo as? User {
                            if user_.id == user?.id {
                                self?.userAvatarView.image = user?.avatar
                            }
                        }
                    },
                    failure: {
                        error in
                        println(error)
                        return
                    })
            }
            var dict: NSDictionary?
            let attributedString = NSMutableAttributedString(
                data: (question.body ?? "").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
                options: [
                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                    NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
                    NSBackgroundColorDocumentAttribute: UIColor.clearColor(),
                    NSViewSizeDocumentAttribute: NSValue(CGSize: CGSize(width: questionBodyView.bounds.width, height: CGFloat.max))],
                documentAttributes: &dict,
                error: nil)!
            questionBodyView.attributedText = attributedString
            viewCountLabel.text = "\(question.viewCount ?? 0)"
            focusCountLabel.text = "\(question.focusCount ?? 0)"
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let attributedString = NSMutableAttributedString(attributedString: questionBodyView.attributedText)
        attributedString.beginEditing()
        attributedString.enumerateAttributesInRange(NSRange(location: 0, length: attributedString.length),
            options: NSAttributedStringEnumerationOptions.allZeros) {
                [weak self] values, range, stop in
                if let self_ = self {
                    if let attachment = values[NSAttachmentAttributeName] as? NSTextAttachment {
                        if let image = attachment.imageForBounds(attachment.bounds, textContainer: NSTextContainer(), characterIndex: range.location) {
                            var size = image.size
                            let attachment = NSTextAttachment()
                            if size.width > self_.questionBodyView.bounds.width {
                                let scale = (self_.questionBodyView.bounds.width) / size.width
                                attachment.image = UIImage(CGImage: image.msr_imageOfSize(CGSize(width: size.width * scale, height: size.height * scale)).CGImage, scale: 1, orientation: image.imageOrientation) // UIImage(CGImage: image.CGImage, scale: scale, orientation: .Up)
                                attributedString.addAttribute(NSAttachmentAttributeName, value: attachment, range: range)
                            }
                        }
                    } else {
                        attributedString.setAttributes([
                            NSFontAttributeName: UIFont.systemFontOfSize(14),
                            NSForegroundColorAttributeName: UIColor.lightTextColor()],
                            range: range)
                    }
                }
        }
        attributedString.endEditing()
        questionBodyView.attributedText = attributedString
    }
    
}
