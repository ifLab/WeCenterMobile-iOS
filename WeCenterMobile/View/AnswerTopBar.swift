//
//  AnswerTopBar.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerTopBar: UIVisualEffectView {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var evaluationImageView: UIImageView!
    @IBOutlet weak var separatorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var agreementCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        msr_addHeightConstraintWithValue(50)
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
        evaluationImageView.image = evaluationImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        separatorWidthConstraint.constant = 0.5
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if superview != nil {
            msr_removeHorizontalEdgeAttachedConstraintsFromSuperview()
        }
    }
    
    override func didMoveToSuperview() {
        if superview != nil {
            msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        }
    }
    
    func update(#answer: Answer) {
        userAvatarView.wc_updateWithUser(answer.user)
        userNameLabel.text = answer.user?.name ?? "匿名用户"
        userSignatureLabel.text = answer.user?.signature ?? ""
        agreementCountLabel.text = "\(answer.agreementCount ?? 0)"
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
