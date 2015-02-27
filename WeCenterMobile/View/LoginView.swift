//
//  LoginView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/18.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class LoginView: Msr.UI.AlertView {
    var usernameField: UITextField!
    var passwordField: UITextField!
    override init() {
        super.init()
        self.cornerRadius = 7
        let cornerRadius = self.cornerRadius
        let borderColor = UIColor.blackColor().CGColor
        var newTextField = {
            () -> UITextField in
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 230, height: 35))
            textField.layer.borderColor = borderColor
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = cornerRadius
            textField.textColor = UIColor.blackColor()
            textField.tintColor = UIColor.whiteColor()
            textField.textAlignment = .Center
            textField.keyboardAppearance = .Default
            textField.clearButtonMode = .WhileEditing
            return textField
        }
        usernameField = newTextField()
        passwordField = newTextField()
        passwordField.secureTextEntry = true
        usernameField.attributedPlaceholder = NSAttributedString(
            string: welcomeStrings["Username"],
            attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
        passwordField.attributedPlaceholder = NSAttributedString(
            string: welcomeStrings["Password"],
            attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
        usernameField.center = CGPoint(x: contentView.center.x, y: 35)
        passwordField.center = CGPoint(x: contentView.center.x, y: 85)
        usernameField.delegate = self
        passwordField.delegate = self
        backgroundColor = UIColor.whiteColor()
        contentView.bounds = CGRect(origin: CGPointZero, size: CGSize(width: contentView.bounds.width, height: 120))
        contentView.addSubview(usernameField)
        contentView.addSubview(passwordField)
    }
}
