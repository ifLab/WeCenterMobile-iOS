//
//  TopicTagListCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicTagListCell: UITableViewCell {
    class ScrollView: UIScrollView {
        override init() {
            super.init()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func touchesShouldBegin(touches: NSSet!, withEvent event: UIEvent!, inContentView view: UIView!) -> Bool {
            return false
        }
        override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
            nextResponder().touchesBegan(touches, withEvent: event)
        }
        override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
            nextResponder().touchesCancelled(touches, withEvent: event)
        }
        override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
            nextResponder().touchesEnded(touches, withEvent: event)
        }
        override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
            nextResponder().touchesCancelled(touches, withEvent: event)
        }
    }
    let scrollView = ScrollView()
    var topicTagViews = [TopicTagView]()
    init(topics: [Topic], width: CGFloat, reuseIdentifier: String!) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        initialize()
        update(topics: topics, width: width)
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
        contentView.addSubview(scrollView)
        textLabel.text = nil
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        backgroundColor = UIColor.paperColorGray300()
    }
    func update(#topics: [Topic], width: CGFloat) {
        for topicTagView in topicTagViews {
            topicTagView.removeFromSuperview()
        }
        topicTagViews.removeAll(keepCapacity: false)
        var offset = CGFloat(10)
        var height = CGFloat(0)
        for topic in topics {
            let topicTagView = TopicTagView(topic: topic)
            topicTagView.frame.origin = CGPoint(x: offset, y: 0)
            offset += topicTagView.bounds.width + 10
            height = topicTagView.bounds.height
            scrollView.addSubview(topicTagView)
            topicTagViews.append(topicTagView)
        }
        frame = CGRect(x: 0, y: 0, width: width, height: height + 10)
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height + 10)
        scrollView.contentSize = CGSize(width: offset, height: height)
    }
}
