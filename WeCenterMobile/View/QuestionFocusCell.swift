//
//  QuestionFocusCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class QuestionFocusCell: UITableViewCell {
    
    let focusImageView = UIImageView(image: UIImage(named: "View_icon").imageWithRenderingMode(.AlwaysTemplate))
    let answerImageView = UIImageView(image: UIImage(named: "Chat_icon").imageWithRenderingMode(.AlwaysTemplate))
    let focusCountLabel = UILabel()
    let answerCountLabel = UILabel()
    let focusButton = BFPaperButton()
    let focusButtonActivityIndicatorView = UIActivityIndicatorView()
    
    private let offset = CGFloat(15)
    
    enum FocusButtonState: Int {
        case Loading = 0
        case NotFocusing = 1
        case Focusing = 2
    }
    
    var focusButtonState: FocusButtonState = .NotFocusing {
       didSet {
            switch focusButtonState {
            case .NotFocusing:
                focusButton.backgroundColor = UIColor.materialGray500()
                focusButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                focusButton.tapCircleColor = UIColor.materialGray300()
                focusButton.setTitle("关注", forState: .Normal) // Needs localization
                focusButton.userInteractionEnabled = true
                focusButtonActivityIndicatorView.activityIndicatorViewStyle = .White
                focusButtonActivityIndicatorView.stopAnimating()
                break
            case .Focusing:
                focusButton.backgroundColor = UIColor.materialGray300()
                focusButton.setTitleColor(UIColor.materialGray800(), forState: .Normal)
                focusButton.tapCircleColor = UIColor.materialGray500()
                focusButton.setTitle("正在关注", forState: .Normal) // Needs localization
                focusButton.userInteractionEnabled = true
                focusButtonActivityIndicatorView.activityIndicatorViewStyle = .Gray
                focusButtonActivityIndicatorView.stopAnimating()
                break
            case .Loading:
                focusButton.setTitle("", forState: .Normal)
                focusButtonActivityIndicatorView.startAnimating()
                focusButton.userInteractionEnabled = false
                break
            default:
                break
            }
        }
    }
    
    init(question: Question?, answerCount: NSNumber?, width: CGFloat, reuseIdentifier: String) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(focusImageView)
        contentView.addSubview(focusCountLabel)
        contentView.addSubview(answerImageView)
        contentView.addSubview(answerCountLabel)
        contentView.addSubview(focusButton)
        focusButton.addSubview(focusButtonActivityIndicatorView)
        focusButtonState = .Loading
        focusImageView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        focusImageView.tintColor = UIColor.materialGray500()
        answerImageView.frame.size = focusImageView.bounds.size
        answerImageView.center.y = focusImageView.center.y
        answerImageView.tintColor = focusImageView.tintColor
        focusButton.frame.size = CGSize(width: 100, height: 40)
        focusButton.center.y = focusImageView.center.y
        focusButton.cornerRadius = 0
        focusButton.titleLabel!.font = .systemFontOfSize(14)
        focusButtonActivityIndicatorView.bounds.size = focusButton.bounds.size
        focusButtonActivityIndicatorView.center = CGPoint(x: focusButton.bounds.width / 2, y: focusButton.bounds.height / 2)
        focusCountLabel.frame.origin.x = focusImageView.frame.origin.x + focusImageView.bounds.width + offset
        focusCountLabel.font = UIFont.systemFontOfSize(14)
        focusCountLabel.center.y = focusImageView.center.y
        focusCountLabel.textColor = focusImageView.tintColor
        answerCountLabel.font = focusCountLabel.font
        answerCountLabel.center.y = focusImageView.center.y
        answerCountLabel.textColor = answerImageView.tintColor
        backgroundColor = UIColor.materialGray100()
        frame.size.height = focusButton.bounds.height
        contentView.frame.size.height = bounds.height
        update(question: question, answerCount: answerCount, width: width)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func update(#question: Question?, answerCount: NSNumber?, width: CGFloat) {
        focusCountLabel.text = question?.focusCount?.stringValue
        answerCountLabel.text = answerCount?.stringValue
        focusButton.msr_userInfo = question?.id ?? -1
        if question?.focusing == nil {
            focusButtonState = .Loading
        } else if question!.focusing! {
            focusButtonState = .Focusing
        } else {
            focusButtonState = .NotFocusing
        }
        focusCountLabel.bounds.size = focusCountLabel.sizeThatFits(CGRectInfinite.size)
        answerImageView.frame.origin.x = focusCountLabel.frame.origin.x + focusCountLabel.bounds.width + offset
        answerCountLabel.bounds.size = answerCountLabel.sizeThatFits(CGRectInfinite.size)
        answerCountLabel.frame.origin.x = answerImageView.frame.origin.x + answerImageView.bounds.width + offset
        focusButton.frame.origin.x = width - focusButton.bounds.width
        frame.size.width = width
        contentView.frame.size.width = bounds.width
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
