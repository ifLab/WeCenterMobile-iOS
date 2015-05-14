//
//  FeaturedArticleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedArticleCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleTagLabel: UILabel!
    @IBOutlet weak var articleUserButton: UIButton!
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
        articleUserButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        articleButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#object: FeaturedObject, updateImage: Bool) {
        let object = object as! FeaturedArticle
        let article = object.article!
        if updateImage {
            userAvatarView.wc_updateWithUser(article.user)
        }
        userNameLabel.text = article.user?.name ?? "匿名用户"
        articleTitle.text = article.title
        articleButton.msr_userInfo = article
        articleUserButton.msr_userInfo = article.user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}