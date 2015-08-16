//
//  SettingsManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/1.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

let CurrentThemeDidChangeNotificationName = "CurrentThemeDidChangeNotification"

let UserDefaultsCurrentThemeNameKey = "UserDefaultsCurrentThemeName"

class SettingsManager: NSObject {
    
    static var defaultManager = SettingsManager()
    
    var currentTheme: Theme = {
        if let path = NSBundle.mainBundle().pathForResource("Themes", ofType: "plist") {
            if let infos = NSDictionary(contentsOfFile: path) {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let current = defaults.objectForKey(UserDefaultsCurrentThemeNameKey) as? String {
                    return Theme(name: current, configuration: infos[current] as? NSDictionary ?? [:])
                } else {
                    if let name = infos.allKeys.first as? String {
                        return Theme(name: name, configuration: infos[name] as? NSDictionary ?? [:])
                    }
                }
            }
        }
        return Theme()
    }() {
        didSet {
            if currentTheme !== oldValue {
                NSNotificationCenter.defaultCenter().postNotificationName(CurrentThemeDidChangeNotificationName, object: nil)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(currentTheme.name, forKey: UserDefaultsCurrentThemeNameKey)
                defaults.synchronize()
            }
        }
    }
    
}
