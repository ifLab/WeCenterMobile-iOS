//
//  AppDelegate.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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
    var currentUser: User?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
//        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
//        let url = directory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
//        NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
//        NetworkManager.clearCookies()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = welcomeViewController
        User.loginWithCookieAndCacheInStorage(
            success: {
                user in
                self.currentUser = user
                self.window!.makeKeyAndVisible()
                dispatch_async(dispatch_get_main_queue()) {
                    self.mainViewController = MainViewController()
                    self.mainViewController.modalTransitionStyle = .CrossDissolve
                    self.welcomeViewController.presentViewController(self.mainViewController, animated: true, completion: nil)
                }
            },
            failure: {
                error in
                self.window!.makeKeyAndVisible()
                println(error)
            })
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        DataManager.defaultManager!.saveChanges(nil)
    }
    
}

