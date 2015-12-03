//
//  AppSecret.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 15/11/24.
//  Copyright © 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import CommonCrypto

func getMobileSignWithPath(var path: String) -> String {
//    NSLog(path)
    let firstSlash = path.rangeOfString("/")?.startIndex
    path.removeRange(path.startIndex...firstSlash!)
    let secondSlash = path.rangeOfString("/")?.startIndex
    if secondSlash != nil {
        path.removeRange(secondSlash!..<path.endIndex)
    }
    path = path + ((NetworkManager.defaultManager?.appSecret) ?? "")
    let str = path.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = CC_LONG(path.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    CC_MD5(str!, strLen, result)
    let hash = NSMutableString()
    for i in 0..<digestLen {
        hash.appendFormat("%02x", result[i])
    }
    result.dealloc(digestLen)    
    return String(format: hash as String)
}