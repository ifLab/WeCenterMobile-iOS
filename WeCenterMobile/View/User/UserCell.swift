//
//  UserCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/10.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var userButtonA: UIButton!
    @IBOutlet weak var userButtonB: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        userButtonB.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }

    func update(#user: User, updateImage: Bool) {
        if updateImage {
            userAvatarView.wc_updateWithUser(user)
        }
        userNameLabel.text = user.name
        /// @TODO: [Back-End][Bug] \n!!!
        userSignatureLabel.text = user.signature?.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        userButtonA.msr_userInfo = user
        userButtonB.msr_userInfo = user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
