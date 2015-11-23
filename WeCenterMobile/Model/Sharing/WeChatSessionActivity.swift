//
//  WeChatSessionActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/21.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import WeChatSDK

class WeChatSessionActivity: WeChatActivity {
    
    override func activityType() -> String? {
        return NSStringFromClass(WeChatSessionActivity.self)
    }
    
    override func activityTitle() -> String? {
        return "微信好友"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Share-WeChatSession")
    }
    
    override func performActivity() {
        let request = SendMessageToWXReq()
        request.bText = false
        request.message = message
        request.scene = Int32(WXSceneSession.rawValue)
        WXApi.sendReq(request)
        activityDidFinish(true)
    }
    
}
