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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    let welcomeViewController = WelcomeViewController()
    var mainViewController: MainViewController!
    var currentUser: User?

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = welcomeViewController
//        User.clearCookies()
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
            }, failure: {
                error in
                self.window!.makeKeyAndVisible()
            })
        return true
    }

    func applicationWillTerminate(application: UIApplication!) {
        self.saveContext()
    }

    func saveContext () {
        var error: NSError? = nil
        if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
            abort()
        }
    }
    
    var managedObjectContext: NSManagedObjectContext {
        if _managedObjectContext == nil {
            _managedObjectContext = NSManagedObjectContext()
            _managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
        }
        return _managedObjectContext!
    }
    
    var _managedObjectContext: NSManagedObjectContext? = nil
    
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            let modelURL = NSBundle.mainBundle().URLForResource("WeCenterMobile", withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
        }
        return _managedObjectModel!
    }
    
    var _managedObjectModel: NSManagedObjectModel? = nil
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if _persistentStoreCoordinator == nil {
            let storeURL = applicationDocumentsDirectory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
            #if DEBUG
                NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
            #endif
            var error: NSError? = nil
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            if _persistentStoreCoordinator!.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: nil,
                URL: storeURL,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true],
                error: &error) == nil {
                #if DEBUG
                    println("Unresolved error \(error!.userInfo)")
                    abort()
                #endif
            }
        }
        return _persistentStoreCoordinator!
    }
    
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil
    
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1] as NSURL
    }
    
}

let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
