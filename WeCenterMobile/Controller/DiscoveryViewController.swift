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
//                ActivityListViewController(listType: .Hot),
//                ActivityListViewController(listType: .New),
//                ActivityListViewController(listType: .Unanswered)
            ])
//        title = DiscoveryStrings["Discovery"]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List-Dots"), style: .Bordered, target: self, action: "showSidebar")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.show(animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return viewControllers[segmentedControl.selectedSegmentIndex].preferredStatusBarStyle()
    }
    
}

