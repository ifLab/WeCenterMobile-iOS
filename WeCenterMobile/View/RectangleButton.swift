//
//  RectangleButton.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/10.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class RectangleButton: UIButton {
    let footerLabel = UILabel()
    override init() {
        super.init()
        frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width / 3, height: 100)
        addSubview(footerLabel)
        backgroundColor = UIColor.msr_materialGray200()
        layer.contentsScale = UIScreen.mainScreen().scale
        footerLabel.frame = CGRect(x: 0, y: 60, width: bounds.width, height: 40)
        footerLabel.textColor = UIColor.grayColor()
        footerLabel.textAlignment = .Center
        footerLabel.font = UIFont.systemFontOfSize(12)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RectangleCountButton: RectangleButton {
    dynamic let countLabel = UILabel() // This should be a bug of Swift. Use a simple 'dynamic' to fix it now.
    override init() {
        super.init()
        addSubview(countLabel)
        countLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 90)
        countLabel.textColor = UIColor.darkGrayColor()
        countLabel.textAlignment = .Center
        countLabel.font = UIFont.systemFontOfSize(32)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RectangleCoverButton: RectangleButton {
    let coverView = UIImageView()
    override init() {
        super.init()
        addSubview(coverView)
        coverView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 90)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}