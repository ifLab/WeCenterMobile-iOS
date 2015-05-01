//
//  TintColor.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/27.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

func TintColorFromColor(color: UIColor?) -> UIColor {
    if color != nil {
        let hue = color!.msr_hue
        let saturation = color!.msr_saturation
        if saturation < 0.1 {
            return UIColor.msr_materialGray()
        }
        return UIColor(hue: hue, saturation: 0.5, brightness: 0.3, alpha: 1)
    } else {
        return UIColor.msr_materialGray()
    }
}
