//
//  String+PlainString.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/24.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation

extension String {
    var wc_plainString: String {
        let attributedString = NSAttributedString(HTMLData: self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), options: nil, documentAttributes: nil)
        return attributedString?.string.msr_stringByRemovingCharactersInSet(NSCharacterSet.newlineCharacterSet()) ?? ""
    }
}
