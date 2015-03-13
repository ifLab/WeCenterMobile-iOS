//
//  ArticlePublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

class ArticlePublishmentActionCell: ActionCell {
    
    @IBOutlet weak var articleTitleLabel: UILabel!
    
    override func update(#action: Action) {
        super.update(action: action)
        let action = action as! ArticlePublishmentAction
        articleTitleLabel.text = action.article.title
        setNeedsLayout()
        layoutIfNeeded()
    }
}