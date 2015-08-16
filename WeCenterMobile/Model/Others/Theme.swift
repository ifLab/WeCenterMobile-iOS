//
//  Theme.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/1.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class Theme {
    
    init() {}
    init(name: String, configuration: NSDictionary) {
        self.name = name
        let titleFontSizeOffset: CGFloat
        if let offset = configuration["Font Size Offset"] as? NSNumber {
            titleFontSizeOffset = CGFloat(offset.doubleValue)
        } else {
            titleFontSizeOffset = 0
        }
        let standardFontSize = UIFont.systemFontSize() + titleFontSizeOffset
        if let titleFontName = configuration["Title Font Name"] as? String {
            if let titleFont = UIFont(name: titleFontName, size: standardFontSize) {
                self.titleFont = titleFont
            } else {
                self.titleFont = UIFont.systemFontOfSize(standardFontSize)
            }
        } else {
            self.titleFont = UIFont.systemFontOfSize(standardFontSize)
        }
        if let subtitleFontName = configuration["Subtitle Font Name"] as? String {
            if let subtitleFont = UIFont(name: subtitleFontName, size: standardFontSize - 2) {
                self.subtitleFont = subtitleFont
            } else {
                self.titleFont = UIFont.systemFontOfSize(standardFontSize - 2)
            }
        } else {
            self.titleFont = UIFont.systemFontOfSize(standardFontSize - 2)
        }
        if let bodyFontName = configuration["Body Font Name"] as? String {
            if let bodyFont = UIFont(name: bodyFontName, size: standardFontSize - 2) {
                self.bodyFont = bodyFont
            } else {
                self.titleFont = UIFont.systemFontOfSize(standardFontSize - 2)
            }
        } else {
            self.titleFont = UIFont.systemFontOfSize(standardFontSize - 2)
        }
        if let footnoteFontName = configuration["Footnote Font Name"] as? String {
            if let footnoteFont = UIFont(name: footnoteFontName, size: standardFontSize - 4) {
                self.footnoteFont = footnoteFont
            } else {
                self.titleFont = UIFont.systemFontOfSize(standardFontSize - 4)
            }
        } else {
            self.titleFont = UIFont.systemFontOfSize(standardFontSize - 4)
        }
        if let backgroundColorARGBA = (configuration["Background Color A"] as? NSNumber)?.unsignedIntValue {
            self.backgroundColorA = %-backgroundColorARGBA
        }
        if let backgroundColorBRGBA = (configuration["Background Color B"] as? NSNumber)?.unsignedIntValue {
            self.backgroundColorB = %-backgroundColorBRGBA
        }
        if let borderColorARGBA = (configuration["Border Color A"] as? NSNumber)?.unsignedIntValue {
            self.borderColorA = %-borderColorARGBA
        }
        if let borderColorBRGBA = (configuration["Border Color B"] as? NSNumber)?.unsignedIntValue {
            self.borderColorB = %-borderColorBRGBA
        }
        if let controlColorARGBA = (configuration["Control Color A"] as? NSNumber)?.unsignedIntValue {
            self.controlColorA = %-controlColorARGBA
        }
        if let controlColorBRGBA = (configuration["Control Color B"] as? NSNumber)?.unsignedIntValue {
            self.controlColorB = %-controlColorBRGBA
        }
        if let highlightColorRGBA = (configuration["Highlight Color"] as? NSNumber)?.unsignedIntValue {
            self.highlightColor = %-highlightColorRGBA
        }
        if let titleTextColorRGBA = (configuration["Title Text Color"] as? NSNumber)?.unsignedIntValue {
            self.titleTextColor = %-titleTextColorRGBA
        }
        if let subtitleTextColorRGBA = (configuration["Subtitle Text Color"] as? NSNumber)?.unsignedIntValue {
            self.subtitleTextColor = %-subtitleTextColorRGBA
        }
        if let bodyTextColorRGBA = (configuration["Body Text Color"] as? NSNumber)?.unsignedIntValue {
            self.bodyTextColor = %-bodyTextColorRGBA
        }
        if let footnoteTextColorRGBA = (configuration["Footnote Text Color"] as? NSNumber)?.unsignedIntValue {
            self.footnoteTextColor = %-footnoteTextColorRGBA
        }
        if let statusBarStyleRawValue = (configuration["Status Bar Style"] as? NSNumber)?.integerValue {
            if let statusBarStyle = UIStatusBarStyle(rawValue: statusBarStyleRawValue) {
                self.statusBarStyle = statusBarStyle
            }
        }
        if let navigationBarStyleRawValue = (configuration["Navigation Bar Style"] as? NSNumber)?.integerValue {
            if let navigationBarStyle = UIBarStyle(rawValue: navigationBarStyleRawValue) {
                self.navigationBarStyle = navigationBarStyle
            }
        }
        if let toolbarStyleRawValue = (configuration["Tool Bar Style"] as? NSNumber)?.integerValue {
            if let toolbarStyle = UIBarStyle(rawValue: toolbarStyleRawValue) {
                self.toolbarStyle = toolbarStyle
            }
        }
        if let navigationItemColorRawValue = (configuration["Navigation Item Color"] as? NSNumber)?.unsignedIntValue {
            self.navigationItemColor = %-navigationItemColorRawValue
        }
        if let toolbarItemColorRawValue = (configuration["Tool Bar Item Color"] as? NSNumber)?.unsignedIntValue {
            self.toolbarItemColor = %-toolbarItemColorRawValue
        }
        if let backgroundBlurEffectStyleRawValue = (configuration["Background Blur Effect Style"] as? NSNumber)?.integerValue {
            if let backgroundBlurEffectStyle = UIBlurEffectStyle(rawValue: backgroundBlurEffectStyleRawValue) {
                self.backgroundBlurEffectStyle = backgroundBlurEffectStyle
            }
        }
        if let keyboardAppearanceRawValue = (configuration["Keyboard Appearance"] as? NSNumber)?.integerValue {
            if let keyboardAppearance = UIKeyboardAppearance(rawValue: keyboardAppearanceRawValue) {
                self.keyboardAppearance = keyboardAppearance
            }
        }
        if let scrollViewIndicatorStyleRawValue = (configuration["Scroll View Indicator Style"] as? NSNumber)?.integerValue {
            if let scrollViewIndicatorStyle = UIScrollViewIndicatorStyle(rawValue: scrollViewIndicatorStyleRawValue) {
                self.scrollViewIndicatorStyle = scrollViewIndicatorStyle
            }
        }
    }
    
    var name: String = "Default"
    
    var titleFont: UIFont = .preferredFontForTextStyle(UIFontTextStyleHeadline)
    var subtitleFont: UIFont = .preferredFontForTextStyle(UIFontTextStyleSubheadline)
    var bodyFont: UIFont = .preferredFontForTextStyle(UIFontTextStyleBody)
    var footnoteFont: UIFont = .preferredFontForTextStyle(UIFontTextStyleFootnote)
    
    var titleTextColor: UIColor = %-0x000000df
    var subtitleTextColor: UIColor = %-0x0000008a
    var bodyTextColor: UIColor = %-0x0000008a
    var footnoteTextColor: UIColor = %-0x00000042
    
    var backgroundColorA: UIColor = .msr_materialGray200()
    var backgroundColorB: UIColor = .msr_materialGray100()
    
    var borderColorA: UIColor = .msr_materialGray300()
    var borderColorB: UIColor = .msr_materialGray800()
    var controlColorA: UIColor = .msr_materialPurple500()
    var controlColorB: UIColor = .whiteColor()
    var navigationItemColor: UIColor = %-0x00000042
    var toolbarItemColor: UIColor = %-0x00000042
    
    var highlightColor: UIColor = %-0x0000007f
    
    var statusBarStyle: UIStatusBarStyle = .Default
    var navigationBarStyle: UIBarStyle = .Default
    var toolbarStyle: UIBarStyle = .Default
    
    var backgroundBlurEffectStyle: UIBlurEffectStyle = .ExtraLight
    
    var keyboardAppearance: UIKeyboardAppearance = .Default
    
    var scrollViewIndicatorStyle: UIScrollViewIndicatorStyle = .Default
    
}
