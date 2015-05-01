//
//  WeChatShareItem.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/21.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class WeChatShareItem: NSObject {
    init(title: String?, body: String?, image: UIImage?, url: String?) {
        self.title = title
        self.body = body
        self.image = image
        self.url = url
    }
    var title: String?
    var body: String?
    var image: UIImage?
    var url: String?
}
