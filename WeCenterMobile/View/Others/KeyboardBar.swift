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
                backgroundView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                backgroundView!.frame = bounds
                addSubview(backgroundView!)
                sendSubviewToBack(backgroundView!)
            }
        }
    }
    
    lazy var textField: UITextField = {
        let v = UITextField()
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        v.textColor = UIColor.blackColor().colorWithAlphaComponent(0.87)
        v.attributedPlaceholder = NSAttributedString(string: "在此处输入评论……", attributes: [NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.6)])
        v.borderStyle = .None
        v.clearButtonMode = .WhileEditing
        return v
    }()
    
    lazy var publishButton: UIButton = {
        let v = UIButton()
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        v.setTitle("发布", forState: .Normal) // Needs localization
        v.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.87), forState: .Normal)
        v.backgroundColor = UIColor.msr_materialLightBlue()
        v.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.2), forState: .Highlighted)
        return v
    }()
    
    lazy var userAtView: UserAtView = {
        let v = UserAtView()
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        v.hidden = true
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        msr_initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        msr_initialize()
    }
    
    func msr_initialize() {
        let vs = ["t": textField, "b": publishButton, "at": userAtView]
        for (k, v) in vs {
            addSubview(v)
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[t]-5-[b(==75)]|", options: nil, metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[t]|", options: nil, metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[b]|", options: nil, metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[at][t]", options: nil, metrics: nil, views: vs))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[at]", options: nil, metrics: nil, views: vs))
        clipsToBounds = false
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) // bar
        backgroundView!.layer.borderWidth = 0.5
        backgroundView!.layer.borderColor = UIColor.msr_materialGray300().CGColor
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if userAtView.pointInside(convertPoint(point, toView: userAtView), withEvent: event) {
            return true
        }
        return super.pointInside(point, withEvent: event)
    }
    
}
