//
//  LoginViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFViewShaker
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userNameImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var userNameImageViewContainerView: UIVisualEffectView!
    @IBOutlet weak var passwordImageViewContainerView: UIVisualEffectView!
    @IBOutlet weak var userNameFieldUnderline: UIVisualEffectView!
    @IBOutlet weak var passwordFieldUnderline: UIVisualEffectView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonLabel: UILabel!
    @IBOutlet weak var loginActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var titleLabelContainerView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delaysContentTouches = false
        scrollView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIControl.self)
        userNameImageView.msr_imageRenderingMode = .AlwaysTemplate
        passwordImageView.msr_imageRenderingMode = .AlwaysTemplate
        userNameField.attributedPlaceholder = NSAttributedString(string: userNameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        userNameField.tintColor = UIColor.lightTextColor()
        passwordField.tintColor = UIColor.lightTextColor()
        loginButton.msr_setBackgroundImageWithColor(UIColor.whiteColor())
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        loginButton.addTarget(self, action: "login", forControlEvents: .TouchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: "didTouchBlankArea")
        let pan = UIPanGestureRecognizer(target: self, action: "didTouchBlankArea")
        scrollView.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(pan)
        pan.requireGestureRecognizerToFail(tap)
        userNameField.delegate = self
        passwordField.delegate = self
    }
    var firstAppear = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userNameField.text = ""
        passwordField.text = ""
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
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
    
    @IBAction func login() {
        scrollView.msr_resignFirstResponderOfAllSubviews()
        loginButton.hidden = true
        loginButtonLabel.hidden = true
        loginActivityIndicatorView.startAnimating()
        User.loginWithName(userNameField.text,
            password: passwordField.text,
            success: {
                [weak self] user in
                User.currentUser = user
                if let self_ = self {
                    UIView.animateWithDuration(0.5) {
                        self_.loginButton.hidden = false
                        self_.loginButtonLabel.hidden = false
                        self_.loginActivityIndicatorView.stopAnimating()
                    }
                    self_.presentMainViewController()
                }
            },
            failure: {
                [weak self] error in
                if let self_ = self {
                    UIView.animateWithDuration(0.5) {
                        self_.loginButton.hidden = false
                        self_.loginButtonLabel.hidden = false
                        self_.loginActivityIndicatorView.stopAnimating()
                    }
                    let s = AFViewShaker(viewsArray: [self_.userNameImageViewContainerView, self_.userNameField, self_.passwordImageViewContainerView, self_.passwordField, self_.userNameFieldUnderline, self_.passwordFieldUnderline])
                    s.shake()
                }
            })
    }
    
    func presentMainViewController() {
        appDelegate.mainViewController = MainViewController()
        appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === userNameField {
            passwordField.becomeFirstResponder()
        } else if textField === passwordField {
            passwordField.resignFirstResponder()
            login()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return !loginActivityIndicatorView.isAnimating()
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let info = MSRAnimationInfo(keyboardNotification: notification)
        info.animate() {
            [weak self] in
            if let self_ = self {
                let sv = self_.scrollView
                if info.frameEnd.minY == UIScreen.mainScreen().bounds.height {
                    sv.contentInset.bottom = 0
                    self_.titleLabel.alpha = 1
                } else {
                    sv.contentInset.bottom = self_.titleLabelContainerView.frame.maxY + 20
                    self_.titleLabel.alpha = 0
                }
                sv.contentOffset.y = sv.contentSize.height - sv.bounds.height + sv.contentInset.bottom
            }
        }
    }
    
    func didTouchBlankArea() {
        view.msr_resignFirstResponderOfAllSubviews()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
