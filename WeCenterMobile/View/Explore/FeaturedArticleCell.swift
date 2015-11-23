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
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleTagLabel: UILabel!
    @IBOutlet weak var articleUserButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var articleContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [userContainerView, articleContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        badgeLabel.backgroundColor = theme.backgroundColorA
        for v in [containerView, badgeLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        separator.backgroundColor = theme.borderColorA
        for v in [articleUserButton, articleButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, articleTitleLabel] {
            v.textColor = theme.titleTextColor
        }
        badgeLabel.textColor = theme.footnoteTextColor
    }
    
    func update(object object: FeaturedObject) {
        let object = object as! FeaturedArticle
        let article = object.article!
        userAvatarView.wc_updateWithUser(article.user)
        userNameLabel.text = article.user?.name ?? "匿名用户"
        articleTitleLabel.text = article.title
        articleButton.msr_userInfo = article
        articleUserButton.msr_userInfo = article.user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}