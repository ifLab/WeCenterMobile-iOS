//
//  SinaWeiboActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/21.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import SinaWeiboSDK

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
        return UIImage(named: "Share-SinaWeibo")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if WeiboSDK.isWeiboAppInstalled() && WeiboSDK.isCanShareInWeiboAPP() {
            for item in activityItems {
                if item is String {
                    return true
                }
            }
        }
        return false
    }
    
    var message: WBMessageObject!
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        message = WBMessageObject()
        var url: NSURL? = nil
        var title: String? = nil
        var body = ""
        var image: UIImage? = nil
        for item in activityItems {
            switch item {
            case let item as NSURL:
                url = item
            case let item as String:
                if title == nil {
                    title = item
                } else {
                    body += item + "\n"
                }
                break
            case let item as UIImage where image == nil:
                image = item
                break
            default:
                break
            }
        }
        let webpageObject = WBWebpageObject()
        webpageObject.webpageUrl = url?.absoluteString ?? NetworkManager.defaultManager!.website
        webpageObject.objectID = NSBundle.mainBundle().bundleIdentifier
        webpageObject.title = title
        webpageObject.description = body
        webpageObject.thumbnailData = image?.msr_imageOfSize(CGSize(width: 100, height: 100)).dataForPNGRepresentation()
        message.mediaObject = webpageObject
    }
    
    override func performActivity() {
        let request = WBSendMessageToWeiboRequest.requestWithMessage(message) as! WBSendMessageToWeiboRequest
        WeiboSDK.sendRequest(request)
        activityDidFinish(true)
    }
    
}
