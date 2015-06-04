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

var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MSRWeChatAPIDelegate {
    
    lazy var window: UIWindow? = {
        let v = UIWindow(frame: UIScreen.mainScreen().bounds)
        return v
    }()
    lazy var loginViewController: LoginViewController = {
        let vc = NSBundle.mainBundle().loadNibNamed("LoginViewController", owner: nil, options: nil).first as! LoginViewController
        return vc
    }()
    var mainViewController: MainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
//        clearCaches()
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        UIScrollView.msr_installPanGestureTranslationAdjustmentExtension()
        UIScrollView.msr_installTouchesCancellingExtension()
        DTAttributedTextContentView.setLayerClass(DTTiledLayerWithoutFade.self)
        MSRWeChatAPI.registerAppWithID("wx4dc4b980c462893b")
        WeiboSDK.registerApp("3758958382")
        WeiboSDK.enableDebugMode(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTheme", name: CurrentThemeDidChangeNotificationName, object: nil)
        updateTheme()
        window!.rootViewController = loginViewController
        window!.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        DataManager.defaultManager!.saveChanges(nil)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return MSRWeChatAPI.handleOpenURL(url, withDelegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return MSRWeChatAPI.handleOpenURL(url, withDelegate: self)
    }
    
    func clearCaches() {
        NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil))
        NetworkManager.clearCookies()
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
        let url = directory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
        NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
    }
    
    func updateTheme() {
        let theme = SettingsManager.defaultManager.currentTheme
        UINavigationBar.appearance().barStyle = theme.navigationBarStyle
        UINavigationBar.appearance().tintColor = theme.navigationItemColor
    }
    
}
