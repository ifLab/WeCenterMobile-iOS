//
//  AnswerAdditionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class AnswerAdditionCell: BFPaperTableViewCell {
    let additionView = UIView()
    let additionImageView = UIImageView(image: UIImage(named: "Add_icon").imageWithRenderingMode(.AlwaysTemplate))
    let additionTextLabel = UILabel()
    init(reuseIdentifier: String!, width: CGFloat) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        initialize()
        update(width: width)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    func initialize() {
        contentView.addSubview(additionView)
        additionView.addSubview(additionImageView)
        additionView.addSubview(additionTextLabel)
        textLabel.text = ""
        additionImageView.frame = CGRect(x: 0, y: 10, width: 20, height: 20)
        additionImageView.tintColor = UIColor.paperColorGray800()
        additionTextLabel.font = UIFont.systemFontOfSize(12)
        additionTextLabel.text = "添加回答" // Needs localization
        additionTextLabel.frame = CGRect(
            origin: CGPoint(x: additionImageView.frame.origin.x + additionImageView.bounds.width + 10, y: 0),
            size: additionTextLabel.sizeThatFits(CGRectInfinite.size))
        additionTextLabel.center.y = additionImageView.center.y
        additionTextLabel.textColor = additionImageView.tintColor
        additionView.frame = CGRect(x: 0, y: 0, width: additionTextLabel.frame.origin.x + additionTextLabel.bounds.width, height: 40)
        contentView.frame = additionView.bounds
        frame = contentView.bounds
        backgroundColor = UIColor.paperColorGray200()
    }
    func update(#width: CGFloat) {
        additionView.center.x = width / 2
    }
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, bounds.width, 0)
        CGContextClosePath(context)
        CGContextSetStrokeColorWithColor(context, UIColor.paperColorGray400().CGColor)
        CGContextStrokePath(context)
    }
}