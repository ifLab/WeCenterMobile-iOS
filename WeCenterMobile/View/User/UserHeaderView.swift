//
//  UserHeaderView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/9.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserHeaderView: UIView {
    
    @IBOutlet weak var thankCountImageView: UIImageView!
    @IBOutlet weak var likeCountImageView: UIImageView!
    @IBOutlet weak var markCountImageView: UIImageView!
    @IBOutlet weak var agreementCountImageView: UIImageView!
    @IBOutlet weak var thankCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var markCountLabel: UILabel!
    @IBOutlet weak var agreementCountLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    lazy var backButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "Navigation-Back"), forState: .Normal)
        v.tintColor = UIColor.whiteColor()
        return v
    }()
    
    lazy var userAvatarView: MSRRoundedImageView = {
        let v = MSRRoundedImageView(image: defaultUserAvatar)
        return v
    }()
    
    lazy var userNameLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.whiteColor()
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var userSignatureLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.textColor = UIColor.lightTextColor()
        v.font = UIFont.systemFontOfSize(15)
        return v
    }()
    
    lazy var userGenderImageView: UIImageView = {
        let v = UIImageView()
        v.bounds.size = CGSize(width: 16, height: 16)
        v.contentMode = .ScaleAspectFill
        return v
    }()
    
    let maxHeight: CGFloat = 180
    let minHeight: CGFloat = 64
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Manually inform image view to update it's appearences.
        thankCountImageView.tintColorDidChange()
        likeCountImageView.tintColorDidChange()
        markCountImageView.tintColorDidChange()
        agreementCountImageView.tintColorDidChange()
        addSubview(backButton)
        addSubview(userAvatarView)
        addSubview(userNameLabel)
        addSubview(userSignatureLabel)
        addSubview(userGenderImageView)
    }
    
    func update(user user: User) {
        userAvatarView.wc_updateWithUser(user)
        backgroundImageView.wc_updateWithUser(user, withPlaceholder: false)
        userNameLabel.text = user.name ?? "加载中……"
        userNameLabel.sizeToFit()
        userSignatureLabel.text = user.signature ?? ""
        userSignatureLabel.sizeToFit()
        if user.gender != nil && user.gender != .Secret {
            userGenderImageView.image = UIImage(named: user.gender! == .Male ? "User-Gender-Male" : "User-Gender-Female")
            userGenderImageView.tintColor = user.gender! == .Male ? UIColor.msr_materialBlue() : UIColor.msr_materialPink()
        } else {
            userGenderImageView.image = nil
        }
        thankCountLabel.text = user.thankCount?.description ?? "..."
        likeCountLabel.text = user.answerFavoriteCount?.description ?? "..."
        markCountLabel.text = user.markCount?.description ?? "..."
        agreementCountLabel.text = user.agreementCount?.description ?? "..."
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let userAvatarViewBeginSize = CGSize(width: 32, height: 32)
        let userAvatarViewEndSize = CGSize(width: 80, height: 80)
        let titleBeginWidth = userAvatarViewBeginSize.width + 10 + userNameLabel.bounds.width
        let backButtonBeginFrame = CGRect(x: 10, y: 20, width: 30, height: minHeight - 20)
        var backButtonEndFrame = CGRect(x: 10, y: 30, width: 30, height: maxHeight - 30 - 60)
        let userAvatarViewBeginFrame = CGRect(origin: CGPoint(x: bounds.msr_center.x - titleBeginWidth / 2, y: backButtonBeginFrame.msr_center.y - userAvatarViewBeginSize.height / 2), size: userAvatarViewBeginSize)
        var userAvatarViewEndFrame = CGRect(origin: CGPoint(x: backButtonEndFrame.msr_right + 10, y: backButtonEndFrame.msr_center.y - userAvatarViewEndSize.height / 2), size: userAvatarViewEndSize)
        let userNameLabelBeginFrame = CGRect(origin: CGPoint(x: userAvatarViewBeginFrame.msr_right + 10, y: userAvatarViewBeginFrame.msr_center.y - userNameLabel.bounds.height / 2), size: userNameLabel.bounds.size)
        var userNameLabelEndFrame = CGRect(origin: CGPoint(x: userAvatarViewEndFrame.msr_right + 15, y: userAvatarViewEndFrame.msr_top), size: userNameLabel.bounds.size)
        let progress = Double((max(bounds.height, minHeight) - minHeight) / (maxHeight - minHeight))
        bottomView.alpha = CGFloat(max(0, progress * 2 - 1))
        backgroundImageView.alpha = CGFloat(progress)
        userSignatureLabel.alpha = CGFloat(max(0, progress * 2 - 1))
        userGenderImageView.alpha = CGFloat(max(0, progress * 2 - 1))
        if progress <= 1 {
            backButton.frame = MSRLinearInterpolation(a: backButtonBeginFrame, b: backButtonEndFrame, progress: progress)
            userAvatarView.frame = MSRLinearInterpolation(a: userAvatarViewBeginFrame, b: userAvatarViewEndFrame, progress: progress)
            userNameLabel.frame = MSRLinearInterpolation(a: userNameLabelBeginFrame, b: userNameLabelEndFrame, progress: progress)
        } else {
            let offset = bounds.height - maxHeight
            backButtonEndFrame.origin.y += offset
            userAvatarViewEndFrame.origin.y += offset
            userNameLabelEndFrame.origin.y += offset
            backButton.frame = backButtonEndFrame
            userAvatarView.frame = userAvatarViewEndFrame
            userNameLabel.frame = userNameLabelEndFrame
        }
        userGenderImageView.center.y = userNameLabel.center.y
        userGenderImageView.frame.origin.x = userNameLabel.frame.msr_right + 10
        userSignatureLabel.frame = CGRect(x: userNameLabel.frame.msr_left, y: userNameLabel.frame.msr_bottom + 5, width: bounds.width - userNameLabelEndFrame.msr_left - 10, height: userAvatarViewEndFrame.height - userNameLabelEndFrame.height - 5)
        let fittedSize = userSignatureLabel.sizeThatFits(userSignatureLabel.frame.size)
        if fittedSize.height < userSignatureLabel.frame.height {
            userSignatureLabel.frame.size.height = fittedSize.height
        }
    }
    
}