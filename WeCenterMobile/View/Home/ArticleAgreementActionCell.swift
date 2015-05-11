//
//  ArticleAgreementActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/30.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleAgreementActionCell: ActionCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        articleButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        separatorWidthConstraint.constant = 0.5
    }
    
    override func update(#action: Action, updateImage: Bool) {
        super.update(action: action, updateImage: updateImage)
        let action = action as! ArticleAgreementAction
        if updateImage {
            userAvatarView.wc_updateWithUser(action.user)
        }
        userNameLabel.text = action.user?.name ?? "匿名用户"
        articleTitleLabel.text = action.article!.title
        userButton.msr_userInfo = action.user
        articleButton.msr_userInfo = action.article
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
