//
//  WeChatMomentsActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/21.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import MSRWeChatSDK
import UIKit

class WeChatMomentsActivity: UIActivity {
    
    override class func activityCategory() -> UIActivityCategory {
        return .Share
    }
    
    override func activityType() -> String? {
        return NSStringFromClass(WeChatMomentsActivity.self)
    }
    
    override func activityTitle() -> String? {
        return "朋友圈"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "WeChatMoments")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if MSRWeChatAPI.weChatIsInstalled() && MSRWeChatAPI.weChatSupportsOpenAPI() {
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
        for i in activityItems {
            if let i = i as? WeChatShareItem {
                item = i
                break
            }
        }
    }
    
    override func performActivity() {
        MSRWeChatAPI.sendRequestToScene(.Timeline, webpageURL: NSURL(string: item.url ?? NetworkManager.defaultManager!.website)!, title: item.title, description: item.body, thumbnailImage: item.image) {
            [weak self] success in
            self?.activityDidFinish(true)
            return
        }
    }
    
}
