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
        override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
            nextResponder()?.touchesBegan(touches as Set<NSObject>, withEvent: event)
        }
        override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
            nextResponder()?.touchesCancelled(touches as Set<NSObject>, withEvent: event)
        }
        override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
            nextResponder()?.touchesEnded(touches as Set<NSObject>, withEvent: event)
        }
        override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
            nextResponder()?.touchesCancelled(touches as Set<NSObject>, withEvent: event)
        }
    }
    let scrollView = ScrollView()
    var topicTagViews = [TopicTagView]()
    init(topics: [Topic], width: CGFloat, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        initialize()
        update(topics: topics, width: width)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    func initialize() {
        contentView.addSubview(scrollView)
        textLabel!.text = ""
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        backgroundColor = UIColor.msr_materialGray300()
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
