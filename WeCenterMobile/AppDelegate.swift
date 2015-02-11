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

let userStrings = Msr.Data.LocalizedStrings(module: "User", bundle: NSBundle.mainBundle())
let discoveryStrings = Msr.Data.LocalizedStrings(module: "Discovery", bundle: NSBundle.mainBundle())
let welcomeStrings = Msr.Data.LocalizedStrings(module: "Welcome", bundle: NSBundle.mainBundle())

let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
let networkManager = NetworkManager(configuration: NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Configuration", ofType: "plist")!)!)
let dataManager = DataManager(managedObjectContext: appDelegate.managedObjectContext!, managedObjectModel: appDelegate.managedObjectModel)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let welcomeViewController = WelcomeViewController()
    var mainViewController: MainViewController!
    var currentUser: User?

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = welcomeViewController
//        NetworkManager.clearCookies()
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
        saveContext()
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("WeCenterMobile", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
//        NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data."
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: networkManager.website, code: networkManager.internalErrorCode.integerValue, userInfo: dict)
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
}

