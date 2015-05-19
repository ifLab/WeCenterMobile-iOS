//
//  LoginView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/18.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class LoginView: UIView, UIScrollViewDelegate {
    
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
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        msr_resignFirstResponderOfAllSubviews()
    }
    
}
