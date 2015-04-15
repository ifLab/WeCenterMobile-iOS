//
//  QuestionBodyCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import DTCoreText

@objc protocol QuestionBodyCellLinkButtonDelegate {
    optional func didPressLinkButton(linkButton: DTLinkButton)
    optional func didLongPressLinkButton(linkButton: DTLinkButton)
}

class QuestionBodyCell: DTAttributedTextCell, DTAttributedTextContentViewDelegate {
    
    weak var lazyImageViewDelegate: DTLazyImageViewDelegate?
    weak var linkButtonDelegate: QuestionBodyCellLinkButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        attributedTextContextView.backgroundColor = UIColor.clearColor()
        attributedTextContextView.delegate = self
        attributedTextContextView.shouldDrawImages = true
        attributedTextContextView.shouldDrawLinks = true
        attributedTextContextView.edgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
    }

    func update(#question: Question?) {
        if question?.body != nil {
            setHTMLString(question?.body ?? "加载中……",
                options: [
                    DTDefaultFontName: UIFont.systemFontOfSize(0).fontName,
                    DTDefaultFontSize: 16,
                    DTDefaultTextColor: UIColor.lightTextColor(),
                    DTDefaultLineHeightMultiplier: 1.5,
                    DTDefaultLinkColor: UIColor.msr_materialLightBlue800(),
                    DTDefaultLinkDecoration: true
                ])
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment is DTImageTextAttachment {
            let imageView = DTLazyImageView(frame: frame)
            imageView.delegate = lazyImageViewDelegate
            imageView.url = attachment.contentURL
            return imageView
        }
        return nil
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForLink url: NSURL!, identifier: String!, frame: CGRect) -> UIView! {
        let button = DTLinkButton()
        button.URL = url
        button.GUID = identifier
        button.frame = frame
        button.showsTouchWhenHighlighted = true
        button.minimumHitSize = CGSize(width: 44, height: 44)
        button.addTarget(self, action: "linkButton:forEvent:", forControlEvents: .TouchUpInside)
        button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "linkButton:"))
        return button
    }
    
    func linkButton(linkButton: DTLinkButton, forEvent event: UIEvent) {
        linkButtonDelegate?.didPressLinkButton?(linkButton)
    }
    
    func linkButton(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .Began {
            linkButtonDelegate?.didLongPressLinkButton?(recognizer.view as! DTLinkButton)
        }
    }
    
}
