//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    
    override func viewDidLoad() {
        var sidebar = self.navigationController.view.subviews[2] as Msr.UI.Sidebar
        var optionsView = sidebar.scrollView
        let userButton = UIButton(frame: CGRectMake(10, optionsView.frame.height * (1 / 4), optionsView.frame.width - 10, 44))
        userButton.backgroundColor = UIColor.grayColor()
        userButton.addTarget(self, action: "pushUserView", forControlEvents: UIControlEvents.TouchUpInside)
        optionsView.addSubview(userButton)
        
    }

    func pushUserView() {
        self.navigationController.pushViewController(UserMainViewController(), animated: true)
        hideSidebar()
    }
    
    func hideSidebar() {
        var sidebar = self.navigationController.view.subviews[2] as Msr.UI.Sidebar
        sidebar.hide(completion: nil, animated: true)
    }
}
