//
//  UserCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserCell: BFPaperTableViewCell {
    init(user: User, reuseIdentifier: String!) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        imageView.bounds.size = CGSize(width: 60, height: 60)
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.layer.masksToBounds = true
        imageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: user.avatarURL)),
            placeholderImage: Msr.UI.Circle(color: UIColor.paperColorGray200(), radius: imageView.bounds.width / 2).image,
            success: {
                request, response, image in
                self.imageView.image = image.imageOfSize(self.imageView.bounds.size)
            },
            failure: nil)
        textLabel.text = user.name
        detailTextLabel.text = user.signature
        detailTextLabel.textColor = UIColor.grayColor()
    }
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}
