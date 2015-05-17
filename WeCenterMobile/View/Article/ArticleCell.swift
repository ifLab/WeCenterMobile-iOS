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
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        articleButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#article: Article, updateImage: Bool) {
        articleTitleLabel.text = article.title
        articleBodyLabel.text = article.body!.wc_plainString
        userNameLabel.text = article.user?.name ?? "匿名用户"
        dateLabel.text = dateFormatter.stringFromDate(article.date!)
        if updateImage {
            userAvatarView.wc_updateWithUser(article.user)
        }
        userButton.msr_userInfo = article.user
        articleButton.msr_userInfo = article
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
