//
//  KeyboardBar.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/5.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

@objc class KeyboardBar: UIView {
    
    var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if backgroundView != nil {
                backgroundView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                backgroundView!.frame = bounds
                addSubview(backgroundView!)
                sendSubviewToBack(backgroundView!)
            }
        }
    }
    
    lazy var textField: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        let theme = SettingsManager.defaultManager.currentTheme
        v.textColor = theme.subtitleTextColor
        v.attributedPlaceholder = NSAttributedString(string: "在此处输入评论……", attributes: [NSForegroundColorAttributeName: theme.footnoteTextColor])
        v.borderStyle = .None
        v.clearButtonMode = .WhileEditing
        v.keyboardAppearance = theme.keyboardAppearance
        return v
    }()
    
    lazy var publishButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let theme = SettingsManager.defaultManager.currentTheme
        v.setTitle("发布", forState: .Normal) // Needs localization
        v.setTitleColor(theme.subtitleTextColor, forState: .Normal)
        v.backgroundColor = theme.backgroundColorB
        v.msr_borderWidth = 0.5
        v.msr_borderColor = theme.borderColorA
        v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        return v
    }()
    
    lazy var userAtView: UserAtView = {
        let v = UserAtView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidden = true
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        msr_initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        msr_initialize()
    }
    
    func msr_initialize() {
        let vs = ["t": textField, "b": publishButton, "at": userAtView]
        for (_, v) in vs {
            addSubview(v)
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[t]-5-[b(==75)]|", options: [], metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[t]|", options: [], metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[b]|", options: [], metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[at][t]", options: [], metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[at]", options: [], metrics: nil, views: vs))
        clipsToBounds = false
        let theme = SettingsManager.defaultManager.currentTheme
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: theme.backgroundBlurEffectStyle)) // bar
        backgroundView!.msr_borderWidth = 0.5
        backgroundView!.msr_borderColor = theme.borderColorA
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if userAtView.pointInside(convertPoint(point, toView: userAtView), withEvent: event) {
            return true
        }
        return super.pointInside(point, withEvent: event)
    }
    
}
