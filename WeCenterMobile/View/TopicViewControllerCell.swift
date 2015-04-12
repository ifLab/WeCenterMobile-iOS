//
//  TopicViewControllerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/12.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class TopicViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerUserAvatarView: UIImageView!
    @IBOutlet weak var answerUserNameLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: UILabel!
    @IBOutlet weak var answerAgreementCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerUserAvatarView.layer.masksToBounds = true
        answerUserAvatarView.layer.cornerRadius = answerUserAvatarView.bounds.width / 2
    }
    
    func update(#answer: Answer, updateImage: Bool) {
        questionTitleLabel.text = answer.question!.title
        if updateImage {
            answerUserAvatarView.wc_updateWithUser(answer.user)
        }
        let text = NSMutableAttributedString(string: answer.user?.name ?? "匿名用户", attributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(15),
            NSForegroundColorAttributeName: UIColor.whiteColor()])
        if let signature = answer.user?.signature {
            text.appendAttributedString(NSAttributedString(string: "，" + signature, attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(15),
                NSForegroundColorAttributeName: UIColor.lightTextColor()]))
        }
        answerUserNameLabel.text = answer.user?.name ?? "匿名用户"
        answerBodyLabel.text = answer.body
        answerAgreementCountLabel.text = answer.agreementCount?.description ?? "0"
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
