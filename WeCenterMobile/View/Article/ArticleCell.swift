//
//  ArticleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/1.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleBodyLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var articleContainerView: UIView!
    @IBOutlet weak var separator: UIView!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        containerView.msr_borderColor = theme.borderColorA
        separator.backgroundColor = theme.borderColorA
        for v in [userContainerView, articleContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        for v in [userButton, articleButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, articleTitleLabel] {
            v.textColor = theme.titleTextColor
        }
        dateLabel.textColor = theme.footnoteTextColor
        articleBodyLabel.textColor = theme.subtitleTextColor
    }
    
    func update(article article: Article) {
        articleTitleLabel.text = article.title
        articleBodyLabel.text = article.body?.wc_plainString ?? ""
        userNameLabel.text = article.user?.name ?? "匿名用户"
        if let date = article.date {
            dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        userAvatarView.wc_updateWithUser(article.user)
        userButton.msr_userInfo = article.user
        articleButton.msr_userInfo = article
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
