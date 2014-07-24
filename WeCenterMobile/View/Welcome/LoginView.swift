//
//  LoginView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/18.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class LoginView: Msr.UI.AlertView {
    let usernameField: UITextField!
    let passwordField: UITextField!
    let property = Msr.Data.Property(module: "Welcome", bundle: NSBundle.mainBundle())
    let strings = Msr.Data.LocalizedStrings(module: "Welcome", bundle: NSBundle.mainBundle())
    init() {
        super.init()
        self.cornerRadius = 7
        let cornerRadius = self.cornerRadius
        let borderColor = property["Login View"]["Text Field"]["Border Color"].asColor().CGColor
        var newTextField = {
            () -> UITextField in
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 230, height: 35))
            textField.layer.borderColor = borderColor
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = cornerRadius
            textField.textColor = UIColor.whiteColor()
            textField.tintColor = UIColor.whiteColor()
            textField.textAlignment = .Center
            textField.keyboardAppearance = UIKeyboardAppearance.Default
            textField.keyboardType = UIKeyboardType.ASCIICapable
            textField.clearButtonMode = .WhileEditing
            return textField
        }
        usernameField = newTextField()
        passwordField = newTextField()
        usernameField.attributedPlaceholder = NSAttributedString(
            string: strings["Username"],
            attributes: [NSForegroundColorAttributeName: property["Login View"]["Text Field"]["Border Color"].asColor()])
        passwordField.attributedPlaceholder = NSAttributedString(
            string: strings["Password"],
            attributes: [NSForegroundColorAttributeName: property["Login View"]["Text Field"]["Border Color"].asColor()])
        usernameField.center = CGPoint(x: contentView.center.x, y: 35)
        passwordField.center = CGPoint(x: contentView.center.x, y: 85)
        usernameField.delegate = self
        passwordField.delegate = self
        backgroundColor = property["View"]["Background Color"].asColor()
        contentView.bounds = CGRect(origin: CGPointZero, size: CGSize(width: contentView.bounds.width, height: 120))
        contentView.addSubview(usernameField)
        contentView.addSubview(passwordField)
        typealias AlertAction = Msr.UI.AlertAction
        addAction(AlertAction(title: strings["Cancel"], style: .Cancel) { action in })
        addAction(AlertAction(title: strings["Login"], style: .Default) {
            [weak self] action in
            User.loginWithName(self!.usernameField.text,
                password: self!.passwordField.text,
                success: {
                    user in
                    println("USER HAS SUCCESSFULLY LOGGED IN WITH NAME & PASSWORD.")
                    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    let newRootController = appDelegate.generateRootViewController()
                    newRootController.modalTransitionStyle = .CrossDissolve
                    appDelegate.window!.rootViewController.presentViewController(newRootController, animated: true, completion: nil)
                },
                failure: {
                    networkError, serverError in
                    println("USER HAS FAILED TO LOG IN WITH NAME & PASSWORD.")
                    println(networkError)
                    println(serverError)
                })
            return
        })
    }
}
