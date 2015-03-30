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
    @IBOutlet weak var articleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
        articleButton.msr_setBackgroundImageWithColor(articleButton.backgroundColor!)
        articleButton.backgroundColor = UIColor.clearColor()
    }
    
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
