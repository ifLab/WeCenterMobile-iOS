//
//  WelcomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFViewShaker
import UIKit

class WelcomeViewController: UIViewController {
    
    lazy var loginView: LoginView = {
        return NSBundle.mainBundle().loadNibNamed("LoginView", owner: self, options: nil).first as! LoginView
    }()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        view = loginView
        loginView.loginButton.addTarget(self, action: "login", forControlEvents: .TouchUpInside)
    }
    
    var firstAppear: Bool = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            firstAppear = false
            User.loginWithCookiesAndCacheInStorage(
                success: {
                    [weak self] user in
                    User.currentUser = user
                    self?.presentMainViewController()
                },
                failure: nil)
        }
    }
    
    func login() {
        loginView.loginButton.hidden = true
        loginView.loginButtonLabel.hidden = true
        loginView.loginActivityIndicatorView.startAnimating()
        User.loginWithName(loginView.userNameField.text,
            password: loginView.passwordField.text,
            success: {
                [weak self] user in
                User.currentUser = user
                if let self_ = self {
                    UIView.animateWithDuration(0.5) {
                        self_.loginView.loginButton.hidden = false
                        self_.loginView.loginButtonLabel.hidden = false
                        self_.loginView.loginActivityIndicatorView.stopAnimating()
                    }
                    self_.presentMainViewController()
                }
            },
            failure: {
                [weak self] error in
                if let self_ = self {
                    UIView.animateWithDuration(0.5) {
                        self_.loginView.loginButton.hidden = false
                        self_.loginView.loginButtonLabel.hidden = false
                        self_.loginView.loginActivityIndicatorView.stopAnimating()
                    }
                    let v = self_.loginView
                    let s = AFViewShaker(viewsArray: [v.userNameImageViewContainerView, v.userNameField, v.passwordImageViewContainerView, v.passwordField, v.userNameFieldUnderline, v.passwordFieldUnderline])
                    s.shake()
                }
            })
    }
    
    func presentMainViewController() {
        appDelegate.mainViewController = MainViewController()
        appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
