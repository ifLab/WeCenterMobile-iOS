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
import SinaWeiboSDK
import SVProgressHUD
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

var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var window: UIWindow? = {
        let v = UIWindow(frame: UIScreen.mainScreen().bounds)
        return v
    }()
    
    lazy var loginViewController: LoginViewController = {
        let vc = NSBundle.mainBundle().loadNibNamed("LoginViewController", owner: nil, options: nil).first as! LoginViewController
        return vc
    }()
    
    var cacheFileURL: NSURL {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        let url = directory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
        return url
    }
    
    var mainViewController: MainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
//        clearCaches()
        UIScrollView.msr_installPanGestureTranslationAdjustmentExtension()
        UIScrollView.msr_installTouchesCancellingExtension()
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        DTAttributedTextContentView.setLayerClass(DTTiledLayerWithoutFade.self)
        SVProgressHUD.setDefaultMaskType(.Gradient)
        WeiboSDK.registerApp("3758958382")
        WXApi.registerApp("wx4dc4b980c462893b")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTheme", name: CurrentThemeDidChangeNotificationName, object: nil)
        updateTheme()
        window!.rootViewController = loginViewController
        window!.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        try! DataManager.defaultManager!.saveChanges()
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: nil) || WXApi.handleOpenURL(url, delegate: nil)
    }
    
    func clearCaches() {
        NetworkManager.clearCookies()
        do {
            try NSFileManager.defaultManager().removeItemAtURL(cacheFileURL)
        } catch _ {
        }
        DataManager.defaultManager = nil
        DataManager.temporaryManager = nil
    }
    
    func updateTheme() {
        let theme = SettingsManager.defaultManager.currentTheme
        mainViewController?.contentViewController.view.backgroundColor = theme.backgroundColorA
        UINavigationBar.appearance().barStyle = theme.navigationBarStyle
        UINavigationBar.appearance().tintColor = theme.navigationItemColor
    }
    
}
