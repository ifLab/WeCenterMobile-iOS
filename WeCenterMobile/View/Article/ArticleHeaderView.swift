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

class ArticleHeaderView: UIView {
    
    var delegate: ArticleHeaderViewDelegate?
    
    lazy var backButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "Arrow-Left")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        v.tintColor = UIColor.whiteColor()
        return v
    }()
    
    lazy var titleLabelA: UILabel = {
        let v = UILabel()
        v.textAlignment = .Center
        v.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var titleLabelB: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var userAvatarView: MSRRoundedImageView = {
        let v = MSRRoundedImageView(image: defaultUserAvatar)
        return v
    }()
    
    lazy var userNameLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .Right
        v.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        v.font = UIFont.systemFontOfSize(15)
        return v
    }()
    
    lazy var userSignatureLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .Right
        v.textColor = UIColor.lightTextColor()
        v.font = UIFont.systemFontOfSize(12)
        return v
    }()
    
    var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if backgroundView != nil {
                addSubview(backgroundView!)
                sendSubviewToBack(backgroundView!)
                backgroundView!.frame = bounds
                backgroundView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        wc_initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wc_initialize()
    }
    
    func wc_initialize() {
        clipsToBounds = true
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        addSubview(backButton)
        addSubview(titleLabelA)
        addSubview(titleLabelB)
        addSubview(userAvatarView)
        addSubview(userNameLabel)
        addSubview(userSignatureLabel)
    }
    
    func update(#article: Article) {
        userAvatarView.wc_updateWithUser(article.user)
        titleLabelA.text = article.title
        titleLabelB.text = article.title
        titleLabelA.sizeToFit()
        userNameLabel.text = article.user?.name ?? "匿名用户"
        userSignatureLabel.text = article.user?.signature
        invalidateMaxHeight()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let backButtonBeginFrame = CGRect(x: 10, y: 20, width: 30, height: normalHeight - minHeight)
        var backButtonEndFrame = CGRect(x: 10, y: 20, width: 30, height: maxHeight - 40 - 20)
        let userAvatarViewBeginFrame = CGRect(x: bounds.width - 10 - 30, y: backButtonBeginFrame.midY - 15, width: 30, height: 30)
        var userAvatarViewEndFrame = CGRect(x: bounds.width - 10 - 30, y: backButtonEndFrame.maxY, width: 30, height: 30)
        var titleLabelAFrame = CGRect(x: backButtonBeginFrame.maxX + 10, y: backButtonBeginFrame.midY - titleLabelA.bounds.height / 2, width: bounds.width - 100, height: titleLabelA.bounds.height)
        var titleLabelBFrame = CGRect(x: backButtonEndFrame.maxX + 10, y: backButtonEndFrame.minY, width: bounds.width - 60, height: backButtonEndFrame.height)
        var userNameLabelFrame = CGRect(x: 10, y: userAvatarViewEndFrame.minY, width: bounds.width - 64, height: userAvatarViewEndFrame.height / 2)
        var userSignatureLabelFrame = CGRect(x: userNameLabelFrame.minX, y: userNameLabelFrame.maxY, width: userNameLabelFrame.width, height: userAvatarViewEndFrame.height / 2)
        if bounds.height <= normalHeight {
            backButton.frame = backButtonBeginFrame
            userAvatarView.frame = userAvatarViewBeginFrame
            backButton.alpha = 1
            userAvatarView.alpha = 1
            titleLabelA.alpha = 1
            titleLabelB.alpha = 0
            userNameLabel.alpha = 0
            userSignatureLabel.alpha = 0
        } else if bounds.height <= maxHeight {
            let progress = (bounds.height - normalHeight) / (maxHeight - normalHeight)
            backButton.frame = MSRLinearInterpolation(backButtonBeginFrame, backButtonEndFrame, Double(progress))
            userAvatarView.frame = MSRLinearInterpolation(userAvatarViewBeginFrame, userAvatarViewEndFrame, Double(progress))
            backButton.alpha = 1
            userAvatarView.alpha = 1
            titleLabelA.alpha = CGFloat(max(0, progress * -2 + 1))
            titleLabelB.alpha = CGFloat(max(0, progress * 2 - 1))
            userNameLabel.alpha = CGFloat(max(0, progress * 2 - 1))
            userSignatureLabel.alpha = CGFloat(max(0, progress * 2 - 1))
        } else {
            let offset = bounds.height - maxHeight
            backButtonEndFrame.origin.y += offset
            userAvatarViewEndFrame.origin.y += offset
            titleLabelAFrame.origin.y += offset
            titleLabelBFrame.origin.y += offset
            userNameLabelFrame.origin.y += offset
            userSignatureLabelFrame.origin.y += offset
            backButton.frame = backButtonEndFrame
            userAvatarView.frame = userAvatarViewEndFrame
            backButton.alpha = 1
            userAvatarView.alpha = 1
            titleLabelA.alpha = 0
            titleLabelB.alpha = 1
            userNameLabel.alpha = 1
            userSignatureLabel.alpha = 1
        }
        titleLabelA.frame = titleLabelAFrame
        titleLabelB.frame = titleLabelBFrame
        userNameLabel.frame = userNameLabelFrame
        userSignatureLabel.frame = userSignatureLabelFrame
    }
    
    func invalidateMaxHeight() {
        _maxHeightIsInvalid = true
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
            _maxHeight = (titleHeight == oneLineHeight ? 44 : titleHeight + 22) + 20 + 40
        }
        return _maxHeight
    }
    
}
