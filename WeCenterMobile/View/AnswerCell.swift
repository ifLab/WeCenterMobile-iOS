//
//  AnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/29.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerCell: UITableViewCell {
    
    var answer: Answer?

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: MSRMultilineLabel!
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var answerAgreementCountCell: UILabel!
    @IBOutlet weak var answerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarView.layer.masksToBounds = true
        userAvatarView.layer.cornerRadius = userAvatarView.bounds.width / 2
        answerButton.msr_setBackgroundImageWithColor(answerButton.backgroundColor!)
        answerButton.backgroundColor = UIColor.clearColor()
    }
    
    func update(#answer: Answer, updateImage: Bool) {
        self.answer = answer
        userNameLabel.text = answer.user?.name ?? "匿名用户"
        answerBodyLabel.text = answer.body?.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.allZeros, range: nil)
        answerAgreementCountCell.text = "\(answer.agreementCount ?? 0)"
        answerButton.msr_userInfo = answer
        if updateImage {
            userAvatarView.wc_updateWithUser(answer.user)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
