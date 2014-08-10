//
//  DiscoveryViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/30.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class DiscoveryViewController: Msr.UI.SegmentedViewController {
    
    init() {
        super.init(
            frame: UIScreen.mainScreen().bounds,
            toolBarStyle: .Black,
            viewControllers: [
                ActivityListViewController(listType: .Hot),
                ActivityListViewController(listType: .New),
                ActivityListViewController(listType: .Unanswered)
            ])
        title = DiscoveryStrings["Discovery"]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List-Dots"), style: .Bordered, target: self, action: "showSidebar")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func refresh() {
        (viewControllers[segmentedControl.selectedSegmentIndex] as ActivityListViewController).refresh()
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.show(animated: true, completion: nil)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

