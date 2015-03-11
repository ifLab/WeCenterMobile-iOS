//
//  DiscoveryViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/30.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class DiscoveryViewController: MSRSegmentedViewController {
    
    override class var positionOfSegmentedControl: MSRSegmentedControlPosition {
        return .Top
    }
    
    override func msr_initialize() {
        super.msr_initialize()
        setViewControllers([UIViewController(), UIViewController(), UIViewController()], animated: false)
        segmentedControl.indicator = MSRSegmentedControlUnderlineIndicator()
        segmentedControl.tintColor = UIColor.orangeColor()
    }
    
}

