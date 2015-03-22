//
//  MediaPickerController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/22.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

class MediaPickerController: UzysAssetsPickerController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationView = valueForKey("navigationTop") as! UIView
        navigationView.opaque = true
    }
    
}
