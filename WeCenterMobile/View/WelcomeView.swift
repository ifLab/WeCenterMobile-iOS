//
//  WelcomeView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class WelcomeView: UIView {
    
    let logoView = UIImageView(image: UIImage(named: "Logo"))
    let loginButton = UIButton()
    let registerButton = UIButton()
    let strings = Msr.Data.LocalizedStrings(module: "Welcome", bundle: NSBundle.mainBundle())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        var center = self.center
        center.y = frame.height / 3
        logoView.center = center
        addSubview(logoView)
        loginButton.setTitle(strings["Login"], forState: .Normal)
        loginButton.frame = CGRect(x: frame.width / 5, y: frame.height * 3 / 5, width: frame.width * 3 / 5, height: 40)
        loginButton.setBackgroundImage(UIImage.rectangleWithColor(UIColor.blackColor(), size: loginButton.bounds.size), forState: .Normal)
        loginButton.titleLabel.font = UIFont.systemFontOfSize(16)
        addSubview(loginButton)
        registerButton.setTitle(strings["Register"], forState: .Normal)
        registerButton.frame = CGRect(x: frame.width / 5, y: frame.height * 3 / 5 + 60, width: frame.width * 3 / 5, height: 40)
        registerButton.setBackgroundImage(UIImage.rectangleWithColor(UIColor.grayColor(), size: registerButton.bounds.size), forState: .Normal)
        registerButton.titleLabel.font = UIFont.systemFontOfSize(16)
        addSubview(registerButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
