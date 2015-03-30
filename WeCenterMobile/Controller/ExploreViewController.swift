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
    
    override func loadView() {
        super.loadView()
        segmentedControl.indicator = MSRSegmentedControlUnderlineIndicator()
        segmentedControl.tintColor = UIColor.msr_materialBrown200()
        segmentedControl.indicator.tintColor = UIColor.msr_materialBrown500()
        (segmentedControl.backgroundView as! UIToolbar).barStyle = .Black
        view.backgroundColor = UIColor.msr_materialBrown900()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List"), style: .Plain, target: self, action: "showSidebar")
        navigationItem.leftBarButtonItem!.tintColor = UIColor.whiteColor()
        scrollView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barStyle = .Black
        delegate = self
    }
    
    var firstAppear = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            firstAppear = false
            let titles: [(FeaturedObjectListType, String)] = [
                (.Recommended, "推荐"),
                (.Hot, "热门"),
                (.New, "最新"),
                (.Unsolved, "等待回答")]
            // [FeaturedObjectListType: String] is not SequenceType
            var vcs: [UIViewController] = map(titles, {
                (type, title) in
                let vc = FeaturedObjectListViewController(type: type)
                vc.title = title
                return vc
            })
            setViewControllers(vcs, animated: false)
        }
    }
    
    func msr_segmentedViewController(segmentedViewController: MSRSegmentedViewController, didSelectViewController viewController: UIViewController?) {
        (viewController as? FeaturedObjectListViewController)?.segmentedViewControllerDidSelectSelf(segmentedViewController)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
}

