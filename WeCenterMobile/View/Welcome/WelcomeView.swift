//
//  WelcomeView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class WelcomeView: UIView {
    
    let logoView: UIImageView
    let loginButton: UIButton
    let registerButton: UIButton
    let model = Msr.Data.Property(module: "Welcome", bundle: NSBundle.mainBundle())
    let string = Msr.Data.LocalizedStrings(module: "Welcome", bundle: NSBundle.mainBundle())
    
    init(frame: CGRect) {
        loginButton = UIButton()
        registerButton = UIButton()
        logoView = UIImageView(image: UIImage(named: "Logo"))
        super.init(frame: frame)
        backgroundColor = model["View"]["Background Color"].asColor()
        var center = self.center
        center.y = frame.height / 3
        logoView.center = center
        addSubview(logoView)
        loginButton.setTitle(string["Login"], forState: .Normal)
        loginButton.frame = CGRect(x: frame.width / 5, y: frame.height * 3 / 5, width: frame.width * 3 / 5, height: 40)
        loginButton.setBackgroundImage(Msr.UI.Rectangle(color: model["Login Button"]["Background Color"].asColor(), size: loginButton.bounds.size).image, forState: .Normal)
        loginButton.titleLabel.font = UIFont.systemFontOfSize(16)
        addSubview(loginButton)
        registerButton.setTitle(string["Register"], forState: .Normal)
        registerButton.frame = CGRect(x: frame.width / 5, y: frame.height * 3 / 5 + 60, width: frame.width * 3 / 5, height: 40)
        registerButton.setBackgroundImage(Msr.UI.Rectangle(color: model["Register Button"]["Background Color"].asColor(), size: registerButton.bounds.size).image, forState: .Normal)
        registerButton.titleLabel.font = UIFont.systemFontOfSize(16)
        addSubview(registerButton)
    }
    
}
