//
//  UserButton.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/10.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserButton: UIButton {
    let footerLabel = UILabel()
    override init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width / 3, height: 100))
        addSubview(footerLabel)
        setBackgroundImage(Msr.UI.Rectangle(color: %+0xe0e0e0, size: bounds.size).image, forState: .Normal)
        layer.contentsScale = UIScreen.mainScreen().scale
        footerLabel.frame = CGRect(x: 0, y: 60, width: bounds.width, height: 40)
        footerLabel.textColor = UIColor.grayColor()
        footerLabel.textAlignment = .Center
        footerLabel.font = UIFont.systemFontOfSize(12)
    }
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

class UserCountButton: UserButton {
    let countLabel = UILabel()
    override init() {
        super.init()
        addSubview(countLabel)
        countLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 90)
        countLabel.textColor = UIColor.darkGrayColor()
        countLabel.textAlignment = .Center
        countLabel.font = UIFont.systemFontOfSize(32)
    }
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

class UserCoverButton: UserButton {
    let coverView = UIImageView()
    override init() {
        super.init()
        addSubview(coverView)
        coverView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 90)
    }
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}