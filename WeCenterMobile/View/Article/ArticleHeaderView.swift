//
//  ArticleHeaderView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

@objc protocol ArticleHeaderViewDelegate {
    optional func articleHeaderViewMaxHeightDidChange(header: ArticleHeaderView)
}

class ArticleHeaderView: UIView, UIToolbarDelegate {
    
    weak var delegate: ArticleHeaderViewDelegate?
    
    lazy var containerView: UIView = {
        let v = UIView()
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.clipsToBounds = true
        return v
    }()
    
    lazy var backButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "Navigation-Back"), forState: .Normal)
        let theme = SettingsManager.defaultManager.currentTheme
        v.tintColor = theme.navigationItemColor
        return v
    }()
    
    lazy var titleLabelA: UILabel = {
        let v = UILabel()
        v.textAlignment = .Center
        let theme = SettingsManager.defaultManager.currentTheme
        v.textColor = theme.titleTextColor
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var titleLabelB: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        let theme = SettingsManager.defaultManager.currentTheme
        v.textColor = theme.titleTextColor
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var userAvatarViewA: MSRRoundedImageView = {
        let v = MSRRoundedImageView(image: defaultUserAvatar)
        return v
    }()
    
    lazy var userAvatarViewB: MSRRoundedImageView = {
        let v = MSRRoundedImageView(image: defaultUserAvatar)
        return v
    }()
    
    lazy var userButtonA: UIButton = {
        let v = UIButton()
        return v
    }()
    
    lazy var userButtonB: UIButton = {
        let v = UIButton()
        let theme = SettingsManager.defaultManager.currentTheme
        v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        return v
    }()
    
    lazy var userNameLabel: UILabel = {
        let v = UILabel()
        let theme = SettingsManager.defaultManager.currentTheme
        v.textColor = theme.titleTextColor
        v.font = UIFont.systemFontOfSize(15)
        return v
    }()
    
    lazy var userSignatureLabel: UILabel = {
        let v = UILabel()
        let theme = SettingsManager.defaultManager.currentTheme
        v.textColor = theme.titleTextColor
        v.font = UIFont.systemFontOfSize(12)
        return v
    }()
    
    lazy var separator: UIView = {
        let v = UIView()
        let theme = SettingsManager.defaultManager.currentTheme
        v.backgroundColor = theme.borderColorB
        v.hidden = true
        return v
    }()
    
    var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if backgroundView != nil {
                addSubview(backgroundView!)
                sendSubviewToBack(backgroundView!)
                backgroundView!.frame = bounds
                backgroundView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            if frame.width != oldValue.width {
                invalidateMaxHeight()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        wc_initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wc_initialize()
    }
    
    func wc_initialize() {
        addSubview(containerView)
        containerView.frame = containerView.bounds
        let theme = SettingsManager.defaultManager.currentTheme
        let bar = UIToolbar()
        bar.delegate = self
        bar.barStyle = theme.navigationBarStyle
        backgroundView = bar
        for v in [backButton, titleLabelA, titleLabelB, userAvatarViewA, userAvatarViewB, userNameLabel, userSignatureLabel, userButtonA, userButtonB, separator] {
            containerView.addSubview(v)
        }
    }
    
    func update(dataObject dataObject: ArticleViewControllerPresentable) {
        userAvatarViewA.wc_updateWithUser(dataObject.user)
        userAvatarViewB.wc_updateWithUser(dataObject.user)
        titleLabelA.text = dataObject.title
        titleLabelB.text = dataObject.title
        titleLabelA.sizeToFit()
        userNameLabel.text = dataObject.user?.name ?? "匿名用户"
        userSignatureLabel.text = dataObject.user?.signature
        userButtonA.msr_userInfo = dataObject.user
        userButtonB.msr_userInfo = dataObject.user
        invalidateMaxHeight()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let backButtonBeginFrame = CGRect(x: 10, y: 20, width: 30, height: normalHeight - minHeight)
        var backButtonEndFrame = CGRect(x: 10, y: 20, width: 30, height: maxHeight - 50 - 20)
        let userAvatarViewAFrame = CGRect(x: bounds.width - 40, y: backButtonBeginFrame.midY - 15, width: 30, height: 30)
        var userAvatarViewBFrame = CGRect(x: 10, y: backButtonEndFrame.maxY + 10, width: 30, height: 30)
        let userButtonAFrame = userAvatarViewAFrame
        var userButtonBFrame = CGRect(x: 0, y: backButtonEndFrame.maxY, width: bounds.width, height: 50)
        var titleLabelAFrame = CGRect(x: backButtonBeginFrame.maxX + 10, y: backButtonBeginFrame.midY - titleLabelA.bounds.height / 2, width: bounds.width - 100, height: titleLabelA.bounds.height)
        var titleLabelBFrame = CGRect(x: backButtonEndFrame.maxX + 10, y: backButtonEndFrame.minY, width: bounds.width - 60, height: backButtonEndFrame.height)
        var userNameLabelFrame = CGRect(x: userAvatarViewBFrame.maxX + 10, y: userAvatarViewBFrame.minY, width: bounds.width - 64, height: userAvatarViewBFrame.height / 2)
        var userSignatureLabelFrame = CGRect(x: userNameLabelFrame.minX, y: userNameLabelFrame.maxY, width: userNameLabelFrame.width, height: userAvatarViewBFrame.height / 2)
        var separatorFrame = CGRect(x: 0, y: backButtonEndFrame.maxY, width: bounds.width, height: 0.5)
        if bounds.height <= normalHeight {
            backButton.frame = backButtonBeginFrame
            userAvatarViewA.alpha = 1
            userAvatarViewB.alpha = 0
            titleLabelA.alpha = 1
            titleLabelB.alpha = 0
            userButtonA.alpha = 1
            userButtonB.alpha = 0
            userNameLabel.alpha = 0
            userSignatureLabel.alpha = 0
            separator.alpha = 0
        } else if bounds.height <= maxHeight {
            let progress = (bounds.height - normalHeight) / (maxHeight - normalHeight)
            backButton.frame = MSRLinearInterpolation(a: backButtonBeginFrame, b: backButtonEndFrame, progress: Double(progress))
            let alphaA = CGFloat(max(0, progress * -2 + 1))
            let alphaB = CGFloat(max(0, progress * 2 - 1))
            userAvatarViewA.alpha = alphaA
            userAvatarViewB.alpha = alphaB
            titleLabelA.alpha = alphaA
            titleLabelB.alpha = alphaB
            userButtonA.alpha = alphaA
            userButtonB.alpha = alphaB
            userNameLabel.alpha = alphaB
            userSignatureLabel.alpha = alphaB
            separator.alpha = alphaB
        } else {
            let offset = bounds.height - maxHeight
            backButtonEndFrame.origin.y += offset
            userAvatarViewBFrame.origin.y += offset
            userButtonBFrame.origin.y += offset
            titleLabelAFrame.origin.y += offset
            titleLabelBFrame.origin.y += offset
            userNameLabelFrame.origin.y += offset
            userSignatureLabelFrame.origin.y += offset
            separatorFrame.origin.y += offset
            backButton.frame = backButtonEndFrame
            userAvatarViewA.alpha = 0
            userAvatarViewB.alpha = 1
            titleLabelA.alpha = 0
            titleLabelB.alpha = 1
            userNameLabel.alpha = 1
            userSignatureLabel.alpha = 1
            separator.alpha = 1
        }
        titleLabelA.frame = titleLabelAFrame
        titleLabelB.frame = titleLabelBFrame
        userAvatarViewA.frame = userAvatarViewAFrame
        userAvatarViewB.frame = userAvatarViewBFrame
        userButtonA.frame = userButtonAFrame
        userButtonB.frame = userButtonBFrame
        userNameLabel.frame = userNameLabelFrame
        userSignatureLabel.frame = userSignatureLabelFrame
        separator.frame = separatorFrame
    }
    
    func invalidateMaxHeight() {
        _maxHeightIsInvalid = true
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    private var _maxHeight: CGFloat = 0 {
        didSet {
            if _maxHeight != oldValue {
                delegate?.articleHeaderViewMaxHeightDidChange?(self)
            }
        }
    }
    private var _maxHeightIsInvalid: Bool = true
    
    let minHeight: CGFloat = 20
    let normalHeight: CGFloat = 64
    var maxHeight: CGFloat {
        if _maxHeightIsInvalid {
            _maxHeightIsInvalid = false
            let titleHeight = titleLabelB.textRectForBounds(CGRect(origin: CGPointZero, size: CGSize(width: bounds.width - 60, height: CGFloat.max)), limitedToNumberOfLines: 0).height
            let oneLineHeight = titleLabelB.textRectForBounds(CGRectInfinite, limitedToNumberOfLines: 1).height
            _maxHeight = (titleHeight == oneLineHeight ? 44 : titleHeight + 22) + 20 + 50
        }
        return _maxHeight
    }
    
}
