//
//  UserAtView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/5.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

@objc class UserAtView: UIView {
    
    var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if backgroundView != nil {
                addSubview(backgroundView!)
                sendSubviewToBack(backgroundView!)
                backgroundView!.translatesAutoresizingMaskIntoConstraints = true
                backgroundView!.frame = bounds
                backgroundView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            }
        }
    }
    
    lazy var atLabel: UILabel = {
        let v = UILabel()
        let theme = SettingsManager.defaultManager.currentTheme
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = UIFont.systemFontOfSize(14)
        v.text = "@"
        v.textAlignment = .Center
        v.textColor = theme.footnoteTextColor
        v.backgroundColor = theme.backgroundColorA
        return v
    }()
    
    lazy var userNameLabel: UILabel = {
        let v = UILabel()
        let theme = SettingsManager.defaultManager.currentTheme
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = UIFont.systemFontOfSize(12)
        v.text = "用户名"
        v.textColor = theme.subtitleTextColor
        return v
    }()
    
    lazy var removeImageView: UIImageView = {
        let v = UIImageView(image: UITextField.msr_defaltClearButton().imageForState(.Highlighted))
        let theme = SettingsManager.defaultManager.currentTheme
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = theme.footnoteTextColor
        return v
    }()
    
    lazy var removeButton: UIButton = {
        let v = UIButton()
        let theme = SettingsManager.defaultManager.currentTheme
        v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        wc_initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wc_initialize()
    }
    
    func wc_initialize() {
        let theme = SettingsManager.defaultManager.currentTheme
        msr_borderWidth = 0.5
        msr_borderColor = theme.borderColorA
        for v in [atLabel, userNameLabel, removeImageView, removeButton] {
            addSubview(v)
        }
        let vs = ["l": userNameLabel, "x": removeImageView, "at": atLabel]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[at(20)]-5-[l]-5-[x]-5-|", options: [], metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=5)-[l]-(>=5)-|", options: [], metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=5)-[x]-(>=5)-|", options: [], metrics: nil, views: vs))
        atLabel.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        userNameLabel.msr_addCenterYConstraintToSuperview()
        removeImageView.msr_addCenterYConstraintToSuperview()
        removeButton.frame = bounds
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: theme.backgroundBlurEffectStyle))
    }
    
}
