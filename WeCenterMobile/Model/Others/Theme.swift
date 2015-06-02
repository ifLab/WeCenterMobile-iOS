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
    init?(configuration: NSDictionary) {
        let titleFontSizeOffset: CGFloat
        if let offset = configuration["Font Size Offset"] as? NSNumber {
            titleFontSizeOffset = CGFloat(offset.doubleValue)
        } else { return nil }
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
        if let backgroundColorARGBA = configuration["Background Color A"] as? NSNumber {
            self.backgroundColorA = %-backgroundColorARGBA.unsignedIntValue
        } else { return nil }
        if let backgroundColorBRGBA = configuration["Background Color B"] as? NSNumber {
            self.backgroundColorB = %-backgroundColorBRGBA.unsignedIntValue
        } else { return nil }
        if let controlColorRGBA = configuration["Control Color"] as? NSNumber {
            self.controlColor = %-controlColorRGBA.unsignedIntValue
        } else { return nil }
        if let highlightColorRGBA = configuration["Highlight Color"] as? NSNumber {
            self.highlightColor = %-highlightColorRGBA.unsignedIntValue
        } else { return nil }
        if let titleTextColorRGBA = configuration["Title Text Color"] as? NSNumber {
            self.titleTextColor = %-titleTextColorRGBA.unsignedIntValue
        } else { return nil }
        if let subtitleTextColorRGBA = configuration["Subtitle Text Color"] as? NSNumber {
            self.subtitleTextColor = %-subtitleTextColorRGBA.unsignedIntValue
        } else { return nil }
        if let bodyTextColorRGBA = configuration["Body Text Color"] as? NSNumber {
            self.bodyTextColor = %-bodyTextColorRGBA.unsignedIntValue
        } else { return nil }
        if let footnoteTextColorRGBA = configuration["Footnote Text Color"] as? NSNumber {
            self.footnoteTextColor = %-footnoteTextColorRGBA.unsignedIntValue
        } else { return nil }
    }
    
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
    
    var controlColor: UIColor = .msr_materialPurple500()
    var highlightColor: UIColor = %-0x0000007f
    
}
