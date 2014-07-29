//
//  MainViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/26.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    let contentViewController = Msr.UI.NavigationController()
    let sidebar = Msr.UI.Sidebar(width: 200, blurEffectStyle: .Dark)
    var titles = [
        "Home"
    ]
    var viewControllers = [
        HomeViewController()
    ]
    init() {
//        contentViewController.viewControllers = NSMutableArray(object: viewControllers[0])
        contentViewController.pushViewController(viewControllers[0], animated: true, completion: nil)
        super.init(nibName: nil, bundle: nil)
        view.bounds = UIScreen.mainScreen().bounds
        addChildViewController(contentViewController)
        view.addSubview(contentViewController.view)
        view.insertSubview(sidebar, aboveSubview: contentViewController.view)
    }
}
