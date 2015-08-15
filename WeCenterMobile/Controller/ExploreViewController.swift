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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Publishment-Article_Question"), style: .Plain, target: self, action: "didPressPublishButton")
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
    
    func didPressPublishButton() {
        let ac = UIAlertController(title: "发布什么？", message: "选择发布的内容种类。", preferredStyle: .ActionSheet)
        let presentPublishmentViewController: (String, PublishmentViewControllerPresentable) -> Void = {
            [weak self] title, object in
            let vc = NSBundle.mainBundle().loadNibNamed("PublishmentViewControllerA", owner: nil, options: nil).first as! PublishmentViewController
            vc.dataObject = object
            vc.headerLabel.text = title
            self?.presentViewController(vc, animated: true, completion: nil)
        }
        ac.addAction(UIAlertAction(title: "问题", style: .Default) {
            action in
            presentPublishmentViewController("发布问题", Question.temporaryObject())
        })
        ac.addAction(UIAlertAction(title: "文章", style: .Default) {
            action in
            presentPublishmentViewController("发布文章", Article.temporaryObject())
        })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
}

