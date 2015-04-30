//
//  QuestionListViewControllerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/28.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionListViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionBodyLabel: UILabel!
    @IBOutlet weak var questionDateLabel: UILabel!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var userAvatarImageView: MSRRoundedImageView!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    func update(#question: Question, updateImage: Bool) {
        questionTitleLabel.text = question.title
        questionBodyLabel.text = question.body!.wc_plainString
        let attributedString = NSMutableAttributedString(
            string: question.user!.name!,
            attributes: [
                NSForegroundColorAttributeName: UIColor.lightTextColor(),
                NSFontAttributeName: questionDateLabel.font])
        attributedString.appendAttributedString(NSAttributedString(
            string: " \(dateFormatter.stringFromDate(question.date!))",
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.4),
                NSFontAttributeName: questionDateLabel.font]))
        questionDateLabel.attributedText = attributedString
        if updateImage {
            userAvatarImageView.wc_updateWithUser(question.user)
        }
        questionButton.msr_userInfo = question
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
