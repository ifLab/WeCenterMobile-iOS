//
//  SidebarUserView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/29.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import GBDeviceInfo
import UIKit

class SidebarUserView: UIView {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var overlay: UIView!
    
    func update(user user: User?) {
        userAvatarView.wc_updateWithUser(user)
        userNameLabel.text = user?.name ?? "加载中……"
        userSignatureLabel.text = user?.signature ?? "说点什么吧……"
        layoutIfNeeded()
    }
    
    lazy var minHeight: CGFloat = {
        let display = GBDeviceInfo.deviceInfo().display
        let heights: [GBDeviceDisplay: CGFloat] = [
            .DisplayUnknown: 220,
            .DisplayiPad: 220,
            .DisplayiPhone35Inch: 170,
            .DisplayiPhone4Inch: 170,
            .DisplayiPhone47Inch: 200,
            .DisplayiPhone55Inch: 220]
        return heights[display]!
    }()
    
}
