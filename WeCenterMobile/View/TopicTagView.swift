//
//  TopicTagView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicTagView: UILabel {
    init(topic: Topic) {
        super.init()
        text = topic.title
        font = UIFont.systemFontOfSize(14)
        backgroundColor = UIColor.paperColorGray800()
        textColor = UIColor.whiteColor()
        frame = CGRect(origin: CGPointZero, size: sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max)))
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
