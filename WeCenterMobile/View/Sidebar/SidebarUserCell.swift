//
//  SidebarUserCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/31.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class SidebarUserCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        let backgroundIndicator = UIView()
        selectedBackgroundView.addSubview(backgroundIndicator)
        backgroundIndicator.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        backgroundIndicator.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        backgroundIndicator.msr_addLeftAttachedConstraintToSuperview()
        backgroundIndicator.msr_addWidthConstraintWithValue(5)
        backgroundIndicator.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    }
    
    func update(#user: User?, updateImage: Bool) {
        if updateImage {
            userAvatarView.wc_updateWithUser(user)
        }
        userNameLabel.text = user?.name ?? "加载中……"
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}