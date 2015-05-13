//
//  FeaturedArticleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedArticleCell: FeaturedObjectCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var articleTagLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        badgeLabel.layer.borderColor = UIColor.msr_materialGray300().CGColor
        badgeLabel.layer.borderWidth = 0.5
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        articleButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    override func update(#object: FeaturedObject, updateImage: Bool) {
        super.update(object: object, updateImage: updateImage)
        if !objectChanged {
            return
        }
        let object = object as! FeaturedArticle
        if updateImage {
            userAvatarView.wc_updateWithUser(object.article!.user)
        }
        userNameLabel.text = object.article!.user?.name ?? "匿名用户"
        articleTitle.text = object.article!.title
        articleButton.msr_userInfo = object.article
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}