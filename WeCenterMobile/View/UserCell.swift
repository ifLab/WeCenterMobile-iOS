//
//  UserCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    init(user: User, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        imageView!.bounds.size = CGSize(width: 50, height: 50)
        imageView!.layer.cornerRadius = imageView!.bounds.width / 2
        imageView!.layer.masksToBounds = true
        if user.avatarURL != nil {
            imageView!.setImageWithURL(NSURL(string: user.avatarURL!), placeholderImage: UIImage.msr_circleWithColor(UIColor.msr_materialGray200(), radius: imageView!.bounds.width / 2))
        }
        textLabel!.text = user.name
        detailTextLabel!.text = user.signature
        detailTextLabel!.textColor = UIColor.grayColor()
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
