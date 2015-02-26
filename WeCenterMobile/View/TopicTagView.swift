//
//  TopicTagView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicTagView: UIView {
    let label = UILabel()
    init(topic: Topic) {
        super.init()
        addSubview(label)
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.msr_materialGray700()
        backgroundColor = UIColor.msr_materialGray100()
        layer.cornerRadius = 3
        layer.masksToBounds = true
        userInteractionEnabled = false
        update(topic: topic)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    func update(#topic: Topic) {
        label.text = topic.title
        label.frame = CGRect(origin: CGPoint(x: layer.cornerRadius, y: layer.cornerRadius), size: label.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max)))
        frame = CGRect(x: 0, y: 0, width: label.frame.width + label.frame.origin.x * 2, height: label.frame.height + label.frame.origin.y * 2)
    }
}
