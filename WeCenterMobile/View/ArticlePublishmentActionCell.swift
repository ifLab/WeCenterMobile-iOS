//
//  ArticlePublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class ArticlePublishmentActionCell: ActionCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    
    override func update(#action: Action) {
        super.update(action: action)
        let action = action as! ArticlePublishmentAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        articleTitleLabel.text = action.article.title
        setNeedsLayout()
        layoutIfNeeded()
    }
}