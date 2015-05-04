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
        bodyLabel.text = comment.body
        if comment.atUser?.name != nil {
            bodyLabel.text = "@" + comment.atUser!.name! + ": " + (bodyLabel.text ?? "")
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
