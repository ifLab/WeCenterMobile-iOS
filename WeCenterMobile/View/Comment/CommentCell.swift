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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
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
                    NSForegroundColorAttributeName: UIColor.lightTextColor(),
                    NSFontAttributeName: bodyLabel.font]))
        }
        attributedString.appendAttributedString(NSAttributedString(
            string: (comment.body ?? ""),
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.87),
                NSFontAttributeName: bodyLabel.font]))
        bodyLabel.attributedText = attributedString
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
