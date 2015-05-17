//
//  AnswerCellWithQuestionTitle.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/12.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerCellWithQuestionTitle: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerUserAvatarView: MSRRoundedImageView!
    @IBOutlet weak var answerUserNameLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: UILabel!
    @IBOutlet weak var answerAgreementCountLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        containerView.layer.borderColor = UIColor.msr_materialGray300().CGColor
        containerView.layer.borderWidth = 0.5
        answerAgreementCountLabel.layer.borderColor = UIColor.msr_materialGray300().CGColor
        answerAgreementCountLabel.layer.borderWidth = 0.5
        questionButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        answerButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#answer: Answer, updateImage: Bool) {
        questionTitleLabel.text = answer.question!.title
        if updateImage {
            answerUserAvatarView.wc_updateWithUser(answer.user)
        }
        let text = NSMutableAttributedString(string: answer.user?.name ?? "匿名用户", attributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(14),
            NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.87)])
        if let signature = answer.user?.signature?.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()) {
            text.appendAttributedString(NSAttributedString(string: "，" + signature, attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.6)]))
        }
        answerUserNameLabel.attributedText = text
        answerBodyLabel.text = answer.body!.wc_plainString
        answerAgreementCountLabel.text = answer.agreementCount?.description ?? "0"
        questionButton.msr_userInfo = answer.question
        answerButton.msr_userInfo = answer
        userButton.msr_userInfo = answer.user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
