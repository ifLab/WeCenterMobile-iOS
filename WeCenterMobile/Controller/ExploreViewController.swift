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
        let theme = SettingsManager.defaultManager.currentTheme
        segmentedControl.indicator = MSRSegmentedControlUnderlineIndicator()
        segmentedControl.tintColor = theme.titleTextColor
        segmentedControl.indicator.tintColor = theme.subtitleTextColor
        (segmentedControl.backgroundView as! UIToolbar).barStyle = theme.toolbarStyle
        view.backgroundColor = theme.backgroundColorA
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-Root"), style: .Plain, target: self, action: "showSidebar")
        msr_navigationBar!.msr_shadowImageView?.hidden = true
        scrollView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        scrollView.delaysContentTouches = false
        scrollView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
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
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
}

