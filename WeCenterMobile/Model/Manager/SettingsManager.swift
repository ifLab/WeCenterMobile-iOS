//
//  SettingsManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/1.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

var CurrentThemeDidChangeNotificationName = "CurrentThemeDidChangeNotification"

class SettingsManager: NSObject {
    
    static var defaultManager = SettingsManager()
    
    var currentTheme: Theme = {
        if let path = NSBundle.mainBundle().pathForResource("Themes", ofType: "plist") {
            if let infos = NSDictionary(contentsOfFile: path) {
                if let current = infos["Current"] as? String {
                    return Theme(name: current, configuration: infos[current] as? NSDictionary ?? [:])
                } else {
                    return Theme()
                }
            } else {
                return Theme()
            }
        } else {
            return Theme()
        }
    }() {
        didSet {
            if currentTheme !== oldValue {
                NSNotificationCenter.defaultCenter().postNotificationName(CurrentThemeDidChangeNotificationName, object: nil)
            }
        }
    }
    
}
