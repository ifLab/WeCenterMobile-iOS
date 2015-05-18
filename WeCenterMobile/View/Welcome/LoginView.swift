//
//  LoginView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/18.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class LoginView: UIView, UIScrollViewDelegate {
    
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet weak var userNameImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var userNameImageViewContainerView: UIVisualEffectView!
    @IBOutlet weak var passwordImageViewContainerView: UIVisualEffectView!
    @IBOutlet weak var userNameFieldUnderlineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordFieldUnderlineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameFieldUnderline: UIVisualEffectView!
    @IBOutlet weak var passwordFieldUnderline: UIVisualEffectView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameImageView.msr_imageRenderingMode = .AlwaysTemplate
        passwordImageView.msr_imageRenderingMode = .AlwaysTemplate
        userNameField.attributedPlaceholder = NSAttributedString(string: userNameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        userNameField.tintColor = UIColor.lightTextColor()
        passwordField.tintColor = UIColor.lightTextColor()
        userNameFieldUnderlineHeightConstraint.constant = 0.5
        passwordFieldUnderlineHeightConstraint.constant = 0.5
        loginButton.setImage(UIImage.msr_roundedRectangleWithColor(UIColor.msr_materialGray300(), size: loginButton.bounds.size, cornerRadius: (5, 5, 5, 5)), forState: .Normal)
        loginButton.setImage(UIImage.msr_roundedRectangleWithColor(UIColor.msr_materialGray600(), size: loginButton.bounds.size, cornerRadius: (5, 5, 5, 5)), forState: .Highlighted)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        msr_resignFirstResponderOfAllSubviews()
    }
    
}
