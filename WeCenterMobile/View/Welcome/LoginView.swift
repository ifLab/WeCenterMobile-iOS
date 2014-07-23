//
//  LoginView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/18.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class LoginView: Msr.UI.AlertView {
    let usernameField: UITextField
    let model = Msr.Data.Property(module: "Welcome", bundle: NSBundle.mainBundle())
    let strings = Msr.Data.LocalizedStrings(module: "Welcome", bundle: NSBundle.mainBundle())
    init() {
        usernameField = UITextField(frame: CGRect(x: 20, y: 20, width: 230, height: 38))
        super.init()
        usernameField.layer.borderColor = model["Login View"]["Text Field"]["Border Color"].asColor().CGColor
        usernameField.layer.borderWidth = 1
        usernameField.layer.cornerRadius = 7
        usernameField.textColor = UIColor.whiteColor()
        usernameField.tintColor = UIColor.whiteColor()
        usernameField.textAlignment = .Center
        usernameField.attributedPlaceholder = NSAttributedString(
            string: strings["Username"],
            attributes: [NSForegroundColorAttributeName: model["Login View"]["Text Field"]["Border Color"].asColor()])
        usernameField.keyboardAppearance = UIKeyboardAppearance.Default
        usernameField.keyboardType = UIKeyboardType.ASCIICapable
        usernameField.delegate = self
        contentView.backgroundColor = model["View"]["Background Color"].asColor()
        contentView.addSubview(usernameField)
    }
}
