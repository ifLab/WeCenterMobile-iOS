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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        commentButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#comment: Comment, updateImage: Bool) {
        msr_userInfo = comment
        if updateImage {
            userAvatarView.wc_updateWithUser(comment.user)
        }
        userNameLabel.text = comment.user?.name
        var attributedString = NSMutableAttributedString()
        if comment.atUser?.name != nil {
            attributedString.appendAttributedString(NSAttributedString(
                string: "@\(comment.atUser!.name!) ",
                attributes: [
                    NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.6),
                    NSFontAttributeName: bodyLabel.font]))
        }
        attributedString.appendAttributedString(NSAttributedString(
            string: (comment.body ?? ""),
            attributes: [
                NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.87),
                NSFontAttributeName: bodyLabel.font]))
        bodyLabel.attributedText = attributedString
        userButton.msr_userInfo = comment.user
        commentButton.msr_userInfo = comment
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
