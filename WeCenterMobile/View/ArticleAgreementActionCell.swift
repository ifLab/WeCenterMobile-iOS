//
//  ArticleAgreementActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/30.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class ArticleAgreementActionCell: ActionCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    
    override func update(#action: Action) {
        super.update(action: action)
        let action = action as! ArticleAgreementAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        articleTitleLabel.text = action.article.title
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}