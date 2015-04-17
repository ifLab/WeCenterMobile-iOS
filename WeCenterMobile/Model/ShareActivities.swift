//
//  ShareActivities.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/16.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import WeChatSDK

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

class WeChatSessionActivity: UIActivity {
    
    override class func activityCategory() -> UIActivityCategory {
        return .Share
    }
    
    override func activityType() -> String? {
        return NSStringFromClass(WeChatSessionActivity.self)
    }
    
    override func activityTitle() -> String? {
        return "分享给朋友"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "WeChatSession")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            for item in activityItems {
                if item is WeChatShareItem {
                    return true
                }
            }
        }
        return false
    }
    
    var item: WeChatShareItem!
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        item = nil
        for i in activityItems {
            if let i = i as? WeChatShareItem {
                item = i
                break
            }
        }
    }
    
    override func performActivity() {
        let reque
        ShareSDK.shareContent(content, type: ShareTypeWeixiSession, authOptions: nil, shareOptions: nil, statusBarTips: false) {
            [weak self] shareType, responseState, platformShareInfo, errorInfo, end in
            self?.activityDidFinish(true)
            return
        }
    }
    
}