//
//  WelcomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let loginView = LoginView()
    let strings = Msr.Data.LocalizedStrings(module: "Welcome", bundle: NSBundle.mainBundle())
    
    override init() {
        super.init(nibName: nil, bundle: NSBundle.mainBundle())
        let welcomeView = WelcomeView(frame: UIScreen.mainScreen().bounds)
        welcomeView.loginButton.addTarget(self, action: "showLoginView", forControlEvents: .TouchUpInside)
        typealias AlertAction = Msr.UI.AlertAction
        loginView.addAction(AlertAction(title: strings["Cancel"], style: .Cancel) { action in })
        loginView.addAction(AlertAction(title: strings["Login"], style: .Default) {
            [weak self] action in
            User.loginWithName(self!.loginView.usernameField.text,
                password: self!.loginView.passwordField.text,
                success: {
                    user in
                    appDelegate.currentUser = user
                    appDelegate.mainViewController = MainViewController()
                    appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
                    appDelegate.window!.rootViewController.presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
                },
                failure: {
                    error in
                })
            return
            })
        view = welcomeView
        view.addSubview(loginView)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    func showLoginView() {
        loginView.show()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
