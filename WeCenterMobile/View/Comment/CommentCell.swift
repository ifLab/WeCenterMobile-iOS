//
//  CommentCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/2/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        msr_scrollView?.delaysContentTouches = false
        containerView.msr_borderColor = theme.borderColorA
        separator.backgroundColor = theme.borderColorA
        for v in [userContainerView, commentContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
        for v in [userButton, commentButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        userNameLabel.textColor = theme.titleTextColor
    }
    
    func update(comment comment: Comment) {
        msr_userInfo = comment
        userAvatarView.wc_updateWithUser(comment.user)
        userNameLabel.text = comment.user?.name
        let attributedString = NSMutableAttributedString()
        let theme = SettingsManager.defaultManager.currentTheme
        if comment.atUser?.name != nil {
            attributedString.appendAttributedString(NSAttributedString(
                string: "@\(comment.atUser!.name!) ",
                attributes: [
                    NSForegroundColorAttributeName: theme.footnoteTextColor,
                    NSFontAttributeName: bodyLabel.font]))
        }
        attributedString.appendAttributedString(NSAttributedString(
            string: (comment.body ?? ""),
            attributes: [
                NSForegroundColorAttributeName: theme.bodyTextColor,
                NSFontAttributeName: bodyLabel.font]))
        bodyLabel.attributedText = attributedString
        userButton.msr_userInfo = comment.user
        commentButton.msr_userInfo = comment
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
