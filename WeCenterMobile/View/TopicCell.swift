//
//  TopicCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicCell: BFPaperTableViewCell {
    init(topic: Topic, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        imageView.bounds.size = CGSize(width: 50, height: 50)
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.layer.masksToBounds = true
        if topic.imageURL != nil {
            imageView.setImageWithURL(NSURL(string: topic.imageURL!), placeholderImage: UIImage.circleWithColor(UIColor.materialGray200(), radius: imageView.bounds.width / 2))
        }
        textLabel.text = topic.title
        detailTextLabel!.text = topic.introduction
        detailTextLabel!.textColor = UIColor.grayColor()
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
