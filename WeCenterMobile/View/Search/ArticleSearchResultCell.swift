//
//  ArticleSearchResultCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/14.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleSearchResultCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, badgeLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        containerView.backgroundColor = theme.backgroundColorB
        badgeLabel.backgroundColor = theme.backgroundColorA
        articleTitleLabel.textColor = theme.titleTextColor
        badgeLabel.textColor = theme.footnoteTextColor
        articleButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
    }
    
    func update(dataObject dataObject: DataObject) {
        let article = dataObject as! Article
        articleTitleLabel.text = article.title ?? ""
        articleButton.msr_userInfo = article
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
