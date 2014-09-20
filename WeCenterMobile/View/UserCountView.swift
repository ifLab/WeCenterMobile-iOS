//
//  UserCountView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/10.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserCountView: UIView {
    let imageView = UIImageView()
    let countLabel = UILabel()
    override init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width / 4, height: 32))
        addSubview(imageView)
        addSubview(countLabel)
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.center.x = center.x
        imageView.tintColor = UIColor.grayColor()
        countLabel.frame = CGRect(x: 0, y: 24, width: bounds.width, height: 8)
        countLabel.textAlignment = .Center
        countLabel.font = UIFont.systemFontOfSize(10)
        countLabel.textColor = UIColor.grayColor()
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
