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
    @IBOutlet weak var articleTagLabel: UILabel!
    @IBOutlet weak var articleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
        userAvatarView.layer.masksToBounds = true
        articleButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    override func update(#object: FeaturedObject, updateImage: Bool) {
        super.update(object: object, updateImage: updateImage)
        if !objectChanged {
            return
        }
        let object = object as! FeaturedArticle
        if updateImage {
            userAvatarView.wc_updateWithUser(object.article.user)
        }
        userNameLabel.text = object.article.user?.name ?? "匿名用户"
        articleTitle.text = object.article.title
        articleButton.msr_userInfo = object.article
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}