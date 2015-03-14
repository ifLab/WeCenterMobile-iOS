//
//  FeaturedArticleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedArticleCell: FeaturedObjectCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var innerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
        userAvatarView.layer.masksToBounds = true
        innerView.layer.masksToBounds = true
        innerView.layer.cornerRadius = 3
    }
    
    override func update(#object: FeaturedObject) {
        let object = object as! FeaturedArticle
        if let urlString = object.article.user?.avatarURL {
            userAvatarView.setImageWithURL(NSURL(string: urlString))
        }
        userNameLabel.text = object.article.user?.name ?? "匿名用户"
        articleTitle.text = object.article.title
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}