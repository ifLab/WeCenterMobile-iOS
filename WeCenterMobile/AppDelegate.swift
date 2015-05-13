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
import MSRWeChatSDK
import SinaWeiboSDK
import UIKit

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
class AppDelegate: UIResponder, UIApplicationDelegate, MSRWeChatAPIDelegate {
    
    var window: UIWindow?
    let welcomeViewController = WelcomeViewController()
    var mainViewController: MainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        UIScrollView.msr_installPanGestureTranslationAdjustmentExtension()
        UIScrollView.msr_installTouchesCancellingExtension()
//        NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil))
//        NetworkManager.clearCookies()
//        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
//        let url = directory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
//        NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
        DTAttributedTextContentView.setLayerClass(DTTiledLayerWithoutFade.self)
        MSRWeChatAPI.registerAppWithID("wx4dc4b980c462893b")
        WeiboSDK.registerApp("3758958382")
        WeiboSDK.enableDebugMode(true)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = welcomeViewController
        window!.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        DataManager.defaultManager!.saveChanges(nil)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return MSRWeChatAPI.handleOpenURL(url, withDelegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return MSRWeChatAPI.handleOpenURL(url, withDelegate: self)
    }
    
}
