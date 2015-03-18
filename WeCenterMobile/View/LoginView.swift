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
    @IBOutlet weak var userNameFieldUnderlineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordFieldUnderlineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginButton: UIButton!
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: "didTapBlankArea:")
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameImageView.image = userNameImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        passwordImageView.image = passwordImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        userNameField.attributedPlaceholder = NSAttributedString(string: userNameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        userNameField.tintColor = UIColor.lightTextColor()
        passwordField.tintColor = UIColor.lightTextColor()
        userNameFieldUnderlineHeightConstraint.constant = 0.5
        passwordFieldUnderlineHeightConstraint.constant = 0.5
        scrollView.delegate = self
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        msr_resignFirstResponderOfAllSubviews()
    }
    
    func didTapBlankArea(gestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer === gestureRecognizer {
            msr_resignFirstResponderOfAllSubviews()
        }
    }
    
}
