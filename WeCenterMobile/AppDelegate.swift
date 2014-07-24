//
//  AppDelegate.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
//    func insert() {
//        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext)
//        let user = User(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
//        user.name = "刘鸿喆";
//        user.email = "butterfly@msrlab.org"
//        user.uid = 1
//        saveContext()
//    }
//    
//    func select() {
//        let request = NSFetchRequest()
//        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext)
//        request.entity = entity
//        request.returnsObjectsAsFaults = false
//        var error: NSError?
//        let objects = managedObjectContext.executeFetchRequest(request, error: &error)
//        for object in objects {
//            println(object)
//        }
//    }

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        User.clearCookies()
        User.loginWithCookieInStorage(
            success: {
                [weak self] user in
                self!.window!.rootViewController = self!.generateRootViewController()
                self!.window!.makeKeyAndVisible()
                println("USER HAS SUCCESSFULLY LOGGED IN WITH COOKIE IN STORAGE.")
            }, failure: {
                [weak self] in
                self!.window!.rootViewController = WelcomeViewController()
                self!.window!.makeKeyAndVisible()
                println("USER HAS FAILED TO LOG IN WITH COOKIE IN STORAGE.")
            })
        return true
    }

    func applicationWillTerminate(application: UIApplication!) {
        self.saveContext()
    }

    func saveContext () {
        var error: NSError? = nil
        let managedObjectContext = self.managedObjectContext
        if managedObjectContext != nil {
            if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
                abort()
            }
        }
    }
    
    var managedObjectContext: NSManagedObjectContext {
        if !_managedObjectContext {
            let coordinator = persistentStoreCoordinator
            if coordinator != nil {
                _managedObjectContext = NSManagedObjectContext()
                _managedObjectContext!.persistentStoreCoordinator = coordinator
            }
        }
        return _managedObjectContext!
    }
    
    var _managedObjectContext: NSManagedObjectContext? = nil
    
    var managedObjectModel: NSManagedObjectModel {
        if !_managedObjectModel {
            let modelURL = NSBundle.mainBundle().URLForResource("WeCenterMobile", withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
        }
        return _managedObjectModel!
    }
    
    var _managedObjectModel: NSManagedObjectModel? = nil
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if !_persistentStoreCoordinator {
            let storeURL = applicationDocumentsDirectory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
            var error: NSError? = nil
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            #if DEBUG
                NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
            #endif
            if _persistentStoreCoordinator!.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: nil,
                URL: storeURL,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true],
                error: &error) == nil {
                #if DEBUG
                    println("Unresolved error \(error), \(error!.userInfo)")
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
    
    func generateRootViewController() -> UIViewController {
        let homeViewController = HomeViewController(nibName: nil, bundle: NSBundle.mainBundle())
        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.view.addSubview(Msr.UI.Sidebar(width: 200, blurEffectStyle: .Light))
        return navigationController
    }

}

