//
//  ArticleFooterView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleFooterView: UIVisualEffectView {
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disagreeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var leftSeparatorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSeparatorWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for button in [shareButton, agreeButton, disagreeButton, commentButton] {
            button.setImage(button.imageForState(.Normal)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        for constraint in [leftSeparatorWidthConstraint, rightSeparatorWidthConstraint] {
            constraint.constant = 0.5
        }
    }
    
    func update(#article: Article) {
        agreeButton.setTitle(article.agreementCount?.description ?? "", forState: .Normal)
    }
    
}