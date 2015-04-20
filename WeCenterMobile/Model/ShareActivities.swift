//
//  ShareActivities.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/16.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import MSRWeChatSDK
import SinaWeiboSDK
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

class WeChatSessionActivity: UIActivity {
    
    override class func activityCategory() -> UIActivityCategory {
        return .Share
    }
    
    override func activityType() -> String? {
        return NSStringFromClass(WeChatSessionActivity.self)
    }
    
    override func activityTitle() -> String? {
        return "微信"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "WeChatSession")
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
        MSRWeChatAPI.sendRequestToScene(.Session, webpageURL: NSURL(string: item.url ?? NetworkManager.defaultManager!.website)!, title: item.title, description: item.body, thumbnailImage: item.image) {
            [weak self] success in
            self?.activityDidFinish(true)
            return
        }
    }
    
}

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

class SinaWeiboShareItem: NSObject {
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

class SinaWeiboActivity: UIActivity {
    
    override class func activityCategory() -> UIActivityCategory {
        return .Share
    }
    
    override func activityType() -> String? {
        return NSStringFromClass(SinaWeiboActivity.self)
    }
    
    override func activityTitle() -> String? {
        return "新浪微博"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "SinaWeibo")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if WeiboSDK.isWeiboAppInstalled() && WeiboSDK.isCanShareInWeiboAPP() {
            for item in activityItems {
                if item is SinaWeiboShareItem {
                    return true
                }
            }
        }
        return false
    }
    
    var item: SinaWeiboShareItem!
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for i in activityItems {
            if let i = i as? SinaWeiboShareItem {
                item = i
                break
            }
        }
    }
    
    override func performActivity() {
        let message = WBMessageObject()
        let webpageObject = WBWebpageObject()
        webpageObject.webpageUrl = item.url ?? NetworkManager.defaultManager!.website
        webpageObject.objectID = NSBundle.mainBundle().bundleIdentifier
        webpageObject.title = item.title
        webpageObject.description = item.body
        webpageObject.thumbnailData = item.image?.dataForPNGRepresentation()
        message.mediaObject = webpageObject
        let request = WBSendMessageToWeiboRequest.requestWithMessage(message) as! WBSendMessageToWeiboRequest
        WeiboSDK.sendRequest(request)
        activityDidFinish(true)
    }
    
}
