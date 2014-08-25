//
//  QuestionTitleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/23.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation

class QuestionTitleCell: BFPaperTableViewCell {
    let titleLabel = UILabel()
    init(question: Question?, width: CGFloat, reuseIdentifier: String!) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        initialize()
        update(question: question, width: width)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    func initialize() {
        addSubview(titleLabel)
        textLabel.text = nil
        backgroundColor = UIColor.paperColorGray300()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByCharWrapping
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
    }
    func update(#question: Question?, width: CGFloat) {
        titleLabel.text = question?.title
        titleLabel.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: titleLabel.sizeThatFits(CGSize(width: width - 20, height: CGFloat.max)))
        frame = CGRect(x: 0, y: 0, width: titleLabel.frame.width + titleLabel.frame.origin.x * 2, height: titleLabel.frame.height + titleLabel.frame.origin.y * 2)
        contentView.frame = bounds
    }
}
