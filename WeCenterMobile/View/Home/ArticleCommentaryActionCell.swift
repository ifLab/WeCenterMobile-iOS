//
//  ArticleCommentaryActionCell.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 15/12/3.
//  Copyright © 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleCommentaryActionCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var agreementCountLabel: UILabel!
    @IBOutlet weak var commentBodyLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var articleContainerView: UIView!
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var separatorA: UIView!
    @IBOutlet weak var separatorB: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [containerView, agreementCountLabel] {
            v.msr_borderColor = theme.borderColorA
        }
        for v in [userButton, articleButton, commentButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userContainerView, articleContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        for v in [agreementCountLabel, commentContainerView] {
            v.backgroundColor = theme.backgroundColorA
        }
        for v in [separatorA, separatorB] {
            v.backgroundColor = theme.borderColorA
        }
        for v in [userNameLabel, articleTitleLabel] {
            v.textColor = theme.titleTextColor
        }
        for v in [agreementCountLabel, typeLabel, commentBodyLabel] {
            v.textColor = theme.subtitleTextColor
        }
    }
    
    func update(action action: Action) {
        let action = action as! ArticleCommentaryAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        articleTitleLabel.text = action.comment!.article!.title!
        agreementCountLabel.text = "\(action.comment!.agreementCount!)"
        commentBodyLabel.text = action.comment!.body!.wc_plainString
        userButton.msr_userInfo = action.user
        articleButton.msr_userInfo = action.comment!.article
        commentButton.msr_userInfo = action.comment
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
