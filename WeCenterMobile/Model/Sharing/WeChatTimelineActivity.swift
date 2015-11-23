//
//  WeChatTimelineActivity.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/21.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import WeChatSDK

class WeChatTimelineActivity: WeChatActivity {
    
    override func activityType() -> String? {
        return NSStringFromClass(WeChatTimelineActivity.self)
    }
    
    override func activityTitle() -> String? {
        return "朋友圈"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Share-WeChatMoments")
    }
    
    override func performActivity() {
        let request = SendMessageToWXReq()
        request.bText = false
        request.message = message
        request.scene = Int32(WXSceneTimeline.rawValue)
        WXApi.sendReq(request)
        activityDidFinish(true)
    }
    
}
