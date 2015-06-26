//
//  WeChatActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/26.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import WeChatSDK

class WeChatActivity: UIActivity {
    
    override class func activityCategory() -> UIActivityCategory {
        return .Share
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            for item in activityItems {
                if item is String {
                    return true
                }
            }
        }
        return false
    }
    
    var message: WXMediaMessage!
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        message = WXMediaMessage()
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
        let webpageObject = WXWebpageObject()
        webpageObject.webpageUrl = url?.absoluteString ?? NetworkManager.defaultManager!.website
        message.title = title
        message.description = body
        message.thumbData = image?.msr_imageOfSize(CGSize(width: 100, height: 100)).dataForPNGRepresentation()
        message.mediaObject = webpageObject
    }
    
}
