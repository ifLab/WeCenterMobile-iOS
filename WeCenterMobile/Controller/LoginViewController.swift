//
//  LoginViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFViewShaker
import UIKit

enum LoginViewControllerState: Int {
    case Login
    case Registration
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var userNameImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var emailImageViewContainerView: UIVisualEffectView!
    @IBOutlet weak var userNameImageViewContainerView: UIVisualEffectView!
    @IBOutlet weak var passwordImageViewContainerView: UIVisualEffectView!
    @IBOutlet weak var emailFieldUnderline: UIVisualEffectView!
    @IBOutlet weak var userNameFieldUnderline: UIVisualEffectView!
    @IBOutlet weak var passwordFieldUnderline: UIVisualEffectView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonLabel: UILabel!
    @IBOutlet weak var loginActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var titleLabelContainerView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var changeStateButton: UIButton!
    
    var state: LoginViewControllerState = .Login {
        didSet {
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.7,
                options: .BeginFromCurrentState,
                animations: {
                    [weak self] in
                    if let self_ = self {
                        self_.errorMessageLabel.text = ""
                        if self_.state == .Login {
                            self_.emailImageView.alpha = 0
                            self_.emailFieldUnderline.contentView.backgroundColor = UIColor.clearColor()
                            self_.emailField.alpha = 0
                            self_.loginButton.removeTarget(self, action: "register", forControlEvents: .TouchUpInside)
                            self_.loginButton.addTarget(self, action: "login", forControlEvents: .TouchUpInside)
                            self_.loginButtonLabel.text = "登录"
                            self_.changeStateButton.setTitle("没有账号？现在注册！", forState: .Normal)
                        } else {
                            self_.emailField.text = ""
                            self_.emailImageView.alpha = 1
                            self_.emailFieldUnderline.contentView.backgroundColor = UIColor.lightTextColor()
                            self_.emailField.alpha = 1
                            self_.loginButton.removeTarget(self, action: "login", forControlEvents: .TouchUpInside)
                            self_.loginButton.addTarget(self, action: "register", forControlEvents: .TouchUpInside)
                            self_.loginButtonLabel.text = "注册"
                            self_.changeStateButton.setTitle("已有账号？马上登录！", forState: .Normal)
                        }
                    }
                },
                completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Manually inform image view to update it's appearences.
        emailImageView.tintColorDidChange()
        userNameImageView.tintColorDidChange()
        passwordImageView.tintColorDidChange()
        scrollView.delaysContentTouches = false
        scrollView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIControl.self)
        emailField.attributedPlaceholder = NSAttributedString(string: emailField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        userNameField.attributedPlaceholder = NSAttributedString(string: userNameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        emailField.tintColor = UIColor.lightTextColor()
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
        emailField.delegate = self
        userNameField.delegate = self
        passwordField.delegate = self
    }
    
    var firstAppear = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        emailField.text = ""
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
        view.endEditing(true)
        loginButton.hidden = true
        loginButtonLabel.hidden = true
        changeStateButton.hidden = true
        loginActivityIndicatorView.startAnimating()
        User.loginWithName(userNameField.text ?? "",
            password: passwordField.text ?? "",
            success: {
                [weak self] user in
                User.currentUser = user
                if let self_ = self {
                    UIView.animateWithDuration(0.5) {
                        self_.loginButton.hidden = false
                        self_.loginButtonLabel.hidden = false
                        self_.changeStateButton.hidden = false
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
                        self_.changeStateButton.hidden = false
                        self_.loginActivityIndicatorView.stopAnimating()
                    }
                    self_.errorMessageLabel.text = (error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误"
                    let s = AFViewShaker(viewsArray: [self_.userNameImageViewContainerView, self_.userNameField, self_.passwordImageViewContainerView, self_.passwordField, self_.userNameFieldUnderline, self_.passwordFieldUnderline])
                    s.shake()
                }
            })
    }
    
    @IBAction func register() {
        view.endEditing(true)
        loginButton.hidden = true
        loginButtonLabel.hidden = true
        changeStateButton.hidden = true
        errorMessageLabel.text = ""
        loginActivityIndicatorView.startAnimating()
        User.registerWithEmail(emailField.text ?? "",
            name: userNameField.text ?? "",
            password: passwordField.text ?? "",
            success: {
                [weak self] user in
                User.currentUser = user
                if let self_ = self {
                    UIView.animateWithDuration(0.5) {
                        self_.loginButton.hidden = false
                        self_.loginButtonLabel.hidden = false
                        self_.changeStateButton.hidden = false
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
                        self_.changeStateButton.hidden = false
                        self_.loginActivityIndicatorView.stopAnimating()
                    }
                    self_.errorMessageLabel.text = (error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误"
                    let s = AFViewShaker(viewsArray: [self_.userNameImageViewContainerView, self_.userNameField, self_.passwordImageViewContainerView, self_.passwordField, self_.userNameFieldUnderline, self_.passwordFieldUnderline, self_.emailImageViewContainerView, self_.emailField, self_.emailFieldUnderline])
                    s.shake()
                }
            })
    }
    
    func presentMainViewController() {
        appDelegate.mainViewController = MainViewController()
        appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        errorMessageLabel.text = ""
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === emailField {
            userNameField.becomeFirstResponder()
        } else if textField === userNameField {
            passwordField.becomeFirstResponder()
        } else if textField === passwordField {
            passwordField.endEditing(true)
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
        view.endEditing(true)
    }
    
    @IBAction func changeState() {
        state = state == .Login ? .Registration : .Login
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
