//
//  UserListViewControllerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/10.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserListViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    }

    func update(#user: User, updateImage: Bool) {
        if updateImage {
            userAvatarView.wc_updateWithUser(user)
        }
        let text = NSMutableAttributedString(
            string: user.name!,
            attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(16),
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        if user.signature ?? "" != "" {
            text.appendAttributedString(NSAttributedString(
                string: "，" + user.signature!,
                attributes: [
                    NSFontAttributeName: UIFont.systemFontOfSize(16),
                    NSForegroundColorAttributeName: UIColor.lightTextColor()]))
        }
        userLabel.attributedText = text
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
