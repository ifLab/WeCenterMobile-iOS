//
//  AppDelegate.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFNetworking
import CoreData
import DTCoreText
import DTFoundation
import ShareSDK
import UIKit
import WeChatSDK

let userStrings: (String) -> String = {
    return NSLocalizedString($0, tableName: "User", comment: "")
}

let discoveryStrings: (String) -> String = {
    return NSLocalizedString($0, tableName: "Discovery", comment: "")
}

let welcomeStrings: (String) -> String = {
    return NSLocalizedString($0, tableName: "Welcome", comment: "")
}

let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let welcomeViewController = WelcomeViewController()
    var mainViewController: MainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
//        NetworkManager.clearCookies()
//        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
//        let url = directory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
//        NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
        DTAttributedTextContentView.setLayerClass(DTTiledLayerWithoutFade.self)
        ShareSDK.registerApp("6cbcbdd12d80")
        ShareSDK.connectSMS()
        ShareSDK.connectMail()
        ShareSDK.connectAirPrint()
        ShareSDK.connectCopy()
        ShareSDK.connectWeChatWithAppId("wx4dc4b980c462893b", wechatCls: WXApi.self)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = welcomeViewController
        window!.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        DataManager.defaultManager!.saveChanges(nil)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return ShareSDK.handleOpenURL(url, wxDelegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
    }
    
}
