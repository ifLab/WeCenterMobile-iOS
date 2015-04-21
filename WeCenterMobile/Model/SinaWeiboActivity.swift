//
//  SinaWeiboActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/21.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import SinaWeiboSDK
import UIKit

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
