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
        initialize()
        update(topic: topic)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    func initialize() {
        addSubview(label)
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.paperColorGray700()
        backgroundColor = UIColor.paperColorGray100()
        layer.cornerRadius = 3
        layer.masksToBounds = true
        userInteractionEnabled = false
    }
    func update(#topic: Topic) {
        label.text = topic.title
        label.frame = CGRect(origin: CGPoint(x: layer.cornerRadius, y: layer.cornerRadius), size: label.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max)))
        frame = CGRect(x: 0, y: 0, width: label.frame.width + label.frame.origin.x * 2, height: label.frame.height + label.frame.origin.y * 2)
    }
}
