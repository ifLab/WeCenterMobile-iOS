//
//  AnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class AnswerCell: BFPaperTableViewCell {
    let avatarButton = UIButton()
    let agreementCountLabel = UILabel()
    let nameLabel = UILabel()
    let contentLabel = DTAttributedLabel()
    init(answer: Answer?, width: CGFloat, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        initialize()
        update(answer: answer, width: width)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    func initialize() {
        contentView.addSubview(avatarButton)
        contentView.addSubview(agreementCountLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        textLabel!.text = ""
        avatarButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        avatarButton.backgroundColor = UIColor.materialGray200()
        avatarButton.layer.cornerRadius = avatarButton.bounds.width / 2
        avatarButton.layer.masksToBounds = true
        agreementCountLabel.frame = CGRect(x: avatarButton.frame.origin.x, y: avatarButton.frame.origin.y + avatarButton.bounds.height + 5, width: avatarButton.bounds.width, height: 13)
        agreementCountLabel.backgroundColor = UIColor.materialGray700()
        agreementCountLabel.textColor = UIColor.whiteColor()
        agreementCountLabel.font = UIFont.systemFontOfSize(10)
        agreementCountLabel.textAlignment = .Center
        nameLabel.frame = CGRect(x: avatarButton.frame.origin.x + avatarButton.bounds.width + 10, y: avatarButton.frame.origin.y, width: 0, height: 20)
        nameLabel.font = UIFont.systemFontOfSize(14)
        contentLabel.frame = CGRect(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.bounds.height + 3, width: 0, height: 0)
        contentLabel.numberOfLines = 3
        contentLabel.lineBreakMode = .ByCharWrapping
        contentLabel.layoutFrameHeightIsConstrainedByBounds = false
        contentLabel.backgroundColor = UIColor.clearColor()
    }
    func update(#answer: Answer?, width: CGFloat) {
        avatarButton.msr_userInfo = answer?.user
        agreementCountLabel.text = answer?.agreementCount?.stringValue
        nameLabel.text = answer?.user?.name
        nameLabel.frame.size.width = width - nameLabel.frame.origin.x - 10
        contentLabel.frame.size.width = width - contentLabel.frame.origin.x - 10
        contentLabel.attributedString = NSAttributedString(HTMLData: answer?.body?.dataUsingEncoding(NSUTF8StringEncoding),
            options: [
                DTDefaultFontSize: 14,
                DTDefaultTextColor: UIColor.grayColor(),
            ],
            documentAttributes: nil)
        contentLabel.frame = CGRect(origin: contentLabel.frame.origin, size: contentLabel.suggestedFrameSizeToFitEntireStringConstraintedToWidth(contentLabel.frame.size.width))
        frame = CGRect(x: 0, y: 0, width: width, height: max(
            agreementCountLabel.frame.origin.y + agreementCountLabel.bounds.height,
            contentLabel.frame.origin.y + contentLabel.bounds.height) + 10)
    }
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, bounds.width, 0)
        CGContextClosePath(context)
        CGContextSetStrokeColorWithColor(context, UIColor.materialGray400().CGColor)
        CGContextStrokePath(context)
    }
}