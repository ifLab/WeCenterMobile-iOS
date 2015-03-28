//
//  WelcomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    lazy var loginView: LoginView = {
        return NSBundle.mainBundle().loadNibNamed("LoginView", owner: self, options: nil).first as! LoginView
    }()
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                    appDelegate.currentUser = user
                    self?.presentMainViewController()
                },
                failure: {
                    [weak self] error in
                    NSLog("%@, %@, %@", __FILE__, __LINE__, __FUNCTION__, error)
                    return
                })
        }
    }
    
    func login() {
        User.loginWithName(loginView.userNameField.text,
            password: loginView.passwordField.text,
            success: {
                [weak self] user in
                appDelegate.currentUser = user
                self?.presentMainViewController()
            },
            failure: {
                [weak self] error in
                let ac: UIAlertController = UIAlertController(title: "登录失败", message: error.userInfo?[NSLocalizedDescriptionKey] as? String, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self?.presentViewController(ac, animated: true, completion: nil)
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
