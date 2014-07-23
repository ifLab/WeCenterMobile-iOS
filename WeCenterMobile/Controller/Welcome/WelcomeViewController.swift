//
//  WelcomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let loginView: LoginView
    
    init() {
        loginView = LoginView()
        super.init(nibName: nil, bundle: NSBundle.mainBundle())
        UIApplication.sharedApplication().statusBarStyle = preferredStatusBarStyle()
        let welcomeView = WelcomeView(frame: UIScreen.mainScreen().bounds)
        welcomeView.loginButton.addTarget(self, action: "showLoginView", forControlEvents: .TouchUpInside)
        view = welcomeView
        view.addSubview(loginView)
        typealias AlertAction = Msr.UI.AlertAction
        loginView.addAction(AlertAction(title: "A", style: .Cancel, handler: { action in }))
        loginView.addAction(AlertAction(title: "B", style: .Default, handler: { action in }))
        loginView.addAction(AlertAction(title: "C", style: .Destructive, handler: { action in }))
//        loginView.addAction(AlertAction(title: "D", style: .Default, handler: { action in }))
//        loginView.addAction(AlertAction(title: "E", style: .Cancel, handler: { action in }))
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func showLoginView() {
        loginView.show()
    }
    
}
