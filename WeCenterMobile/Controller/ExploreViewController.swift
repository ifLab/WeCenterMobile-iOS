//
//  ExploreViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/30.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class ExploreViewController: MSRSegmentedViewController, MSRSegmentedViewControllerDelegate {
    
    override class var positionOfSegmentedControl: MSRSegmentedControlPosition {
        return .Top
    }
    
    override func msr_initialize() {
        super.msr_initialize()
        let titles: [FeaturedObjectListType: String] = [
            .Recommended: "推荐",
            .Hot: "热门",
            .New: "最新",
            .Unsolved: "等待回答"]
        var vcs = [UIViewController]()
        for (type, title) in titles {
            let vc = FeaturedObjectListViewController(type: type)
            vc.title = title
            vcs.append(vc)
        }
        setViewControllers(vcs, animated: false)
        selectViewControllerAtIndex(0, animated: false)
        msr_segmentedViewController(self, didSelectViewController: vcs[0])
        delegate = self
    }
    
    override func loadView() {
        super.loadView()
        segmentedControl.indicator = MSRSegmentedControlUnderlineIndicator()
        segmentedControl.tintColor = UIColor.msr_materialBrown200()
        segmentedControl.indicator.tintColor = UIColor.msr_materialBrown500()
        (segmentedControl.backgroundView as! UIToolbar).barStyle = .Black
        view.backgroundColor = UIColor.msr_materialBrown900()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List"), style: .Plain, target: self, action: "showSidebar")
        navigationItem.leftBarButtonItem!.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController!.navigationBar.barStyle = .Black
    }
    
    func msr_segmentedViewController(segmentedViewController: MSRSegmentedViewController, didSelectViewController viewController: UIViewController) {
        (viewController as! FeaturedObjectListViewController).segmentedViewControllerDidSelectSelf(segmentedViewController)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.toggleShow(animated: true)
    }
    
}

