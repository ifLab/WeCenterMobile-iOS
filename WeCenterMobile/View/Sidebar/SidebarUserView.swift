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
    @IBOutlet weak var searchButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchButton.setImage(searchButton.imageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }
    
    func update(#user: User?, updateImage: Bool) {
        if updateImage {
            userAvatarView.wc_updateWithUser(user)
        }
        userNameLabel.text = user?.name ?? "加载中……"
        userSignatureLabel.text = user?.signature ?? "说点什么吧……"
        layoutIfNeeded()
    }
    
    lazy var minHeight: CGFloat = {
        let display = GBDeviceInfo.deviceInfo().display
        let heights: [GBDeviceDisplay: CGFloat] = [
            .DisplayUnknown: 200,
            .DisplayiPad: 200,
            .DisplayiPhone35Inch: 160,
            .DisplayiPhone4Inch: 160,
            .DisplayiPhone47Inch: 200,
            .DisplayiPhone55Inch: 220]
        return heights[display]!
    }()
    
}
