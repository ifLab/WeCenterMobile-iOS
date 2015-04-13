//
//  MainViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/26.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    lazy var contentViewController: MSRNavigationController = {
        [weak self] in
        let vc = MSRNavigationController(rootViewController: self!.viewControllerAtIndex(0))
        vc.view.backgroundColor = UIColor.msr_materialBlueGray800()
        return vc
    }()
    let sidebar = MSRSidebar(width: 200, edge: .Left)
    lazy var tableView: UITableView = {
        [weak self] in
        let v = ButtonTouchesCancelableTableView(frame: CGRectZero, style: .Grouped)
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.clearColor()
        v.delegate = self
        v.dataSource = self
        v.separatorColor = UIColor.clearColor()
        v.separatorStyle = .None
        v.showsVerticalScrollIndicator = false
        return v
    }()
    lazy var userCell: SidebarUserCell = {
        [weak self] in
        let cell = NSBundle.mainBundle().loadNibNamed("SidebarUserCell", owner: self?.tableView, options: nil).first as! SidebarUserCell
        cell.update(user: User.currentUser, updateImage: true)
        return cell
    }()
    lazy var cells: [SidebarCategoryCell] = {
        [weak self] in
        return map([
            ("Home", "首页"),
            ("Explore", "发现"),
            ("Test", "测试"),
            ("Test", "测试"),
            ("Test", "测试"),
            ("Logout", "注销")]) {
                let cell = NSBundle.mainBundle().loadNibNamed("SidebarCategoryCell", owner: self?.tableView, options: nil).first as! SidebarCategoryCell
                cell.update(image: UIImage(named: "Sidebar" + $0.0)!, title: $0.1)
                return cell
            }
    }()
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    override func loadView() {
        super.loadView()
        contentViewController.interactivePopGestureRecognizer.requireGestureRecognizerToFail(sidebar.screenEdgePanGestureRecognizer)
        addChildViewController(contentViewController)
        view.addSubview(contentViewController.view)
        view.insertSubview(sidebar, aboveSubview: contentViewController.view)
        sidebar.contentView.addSubview(tableView)
        tableView.msr_addAllEdgeAttachedConstraintsToSuperview()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: false, scrollPosition: .None)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return cells.count - 1
        } else {
            return 1
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0 {
            cell = userCell
        } else if indexPath.section == 1 {
            cell = cells[indexPath.row]
        } else {
            cell = cells.last!
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sidebar.collapse()
        if indexPath.section == 0 {
            contentViewController.setViewControllers([UserViewController(user: User.currentUser!)], animated: true)
        } else if indexPath.section == 1 {
            contentViewController.setViewControllers([viewControllerAtIndex(indexPath.row)], animated: true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140
        } else {
            return 60
        }
    }
    var svc: MSRSegmentedViewController!
    var sc: MSRSegmentedControl!
    var slider: UISlider!
    var button: UIButton!
    var toolBar: UIToolbar!
    func viewControllerAtIndex(index: Int) -> UIViewController {
        var viewController: UIViewController! = nil
        switch index {
        case 0:
            viewController = HomeViewController(user: User.currentUser!)
            break
        case 1:
            viewController = ExploreViewController()
            break
        case 2:
            viewController = TestViewController(statusBarStyle: .Default)
            break
        case 3:
            viewController = UIViewController()
            slider = UISlider(frame: CGRectZero)
            button = UIButton(frame: CGRectZero)
            toolBar = UIToolbar()
            sc = MSRSegmentedControl(segments: [
                MSRDefaultSegment(title: "个人收藏", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20))),
                MSRDefaultSegment(title: "最近通话", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20))),
                MSRDefaultSegment(title: "通讯录", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20))),
                MSRDefaultSegment(title: "拨号键盘", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20)))])
            viewController.view.addSubview(sc)
            viewController.view.addSubview(slider)
            viewController.view.addSubview(button)
            viewController.view.backgroundColor = UIColor.whiteColor()
            sc.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            sc.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
            sc.msr_addHeightConstraintWithValue(50)
            sc.msr_addBottomAttachedConstraintToSuperview()
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ADD", style: .Plain, target: self, action: "ADD_NEW_LABEL")
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "REMOVE", style: .Plain, target: self, action: "REMOVE_LABEL")
            sc.addTarget(self, action: "SEGMENT_VALUE_DID_CHANGED", forControlEvents: .ValueChanged)
            slider.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            slider.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
            slider.msr_addTopAttachedConstraintToSuperview()
            slider.msr_topAttachedConstraint!.constant = 200
            slider.addTarget(self, action: "CHANGE_INDICATOR_POSITION", forControlEvents: .ValueChanged)
            button.setTitle("CHANGE TINT COLOR", forState: .Normal)
            button.msr_setBackgroundImageWithColor(sc.indicator.tintColor)
            button.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            button.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
            button.msr_addTopAttachedConstraintToSuperview()
            button.msr_topAttachedConstraint!.constant = 300
            button.msr_addHeightConstraintWithValue(44)
            button.addTarget(self, action: "CHANGE_SEGMENTED_CONTROL_TINT_COLOR", forControlEvents: .TouchUpInside)
            sc.backgroundView = toolBar
            sc.indicator = MSRSegmentedControlUnderlineIndicator()
            break
        case 4:
            var viewControllers = [UIViewController]()
            for i in 1...10 {
                let vc = UIViewController()
                vc.view = UIScrollView()
                (vc.view as! UIScrollView).alwaysBounceVertical = true
                vc.view.backgroundColor = UIColor.msr_randomColor(opaque: true)
                vc.title = "第\(i)个"
                viewControllers.append(vc)
            }
            svc = MSRSegmentedViewController(viewControllers: viewControllers)
            svc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "ADD", style: .Plain, target: self, action: "ADD_NEW_VIEW_CONTROLLER")
            svc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "REMOVE", style: .Plain, target: self, action: "REMOVE_VIEW_CONTROLLER")
            viewController = svc
            break
        default:
            break
        }
        return viewController
    }
    func ADD_NEW_LABEL() {
        sc.insertSegment(MSRDefaultSegment(title: "NEW", image: UIImage.msr_rectangleWithColor(UIColor.purpleColor(), size: CGSize(width: 20, height: 20))), atIndex: sc.numberOfSegments >= 1 ? 1 : 0, animated: true)
    }
    func REMOVE_LABEL() {
        sc.removeSegmentAtIndex(sc.numberOfSegments > 1 ? 1 : 0, animated: true)
    }
    func ADD_NEW_VIEW_CONTROLLER() {
        svc.insertViewController(
            {
                let vc = UIViewController()
                vc.view = UIScrollView()
                (vc.view as! UIScrollView).alwaysBounceVertical = true
                vc.view.backgroundColor = UIColor.msr_randomColor(opaque: true)
                vc.title = "NEW"
                return vc
            }(),
            atIndex: svc.numberOfViewControllers >= 1 ? 1 : 0,
            animated: true)
    }
    func REMOVE_VIEW_CONTROLLER() {
        svc.removeViewControllerAtIndex(svc.numberOfViewControllers > 1 ? 1 : 0, animated: true)
    }
    func CHANGE_INDICATOR_POSITION() {
        if sc.numberOfSegments >= 1 {
            sc.setIndicatorPosition(slider.value * Float(sc.numberOfSegments - 1), animated: false)
            sc.scrollIndicatorToCenterAnimated(false)
        }
    }
    func SEGMENT_VALUE_DID_CHANGED() {
        if !slider.tracking {
            if sc.indicatorPosition == nil || sc.numberOfSegments <= 1 {
                slider.value = 0
            } else {
                slider.value = sc.indicatorPosition! / Float(sc.numberOfSegments - 1)
            }
        }
        println("index: \(sc.selectedSegmentIndex), position: \(sc.indicatorPosition), index changed: \(sc.selectedSegmentIndexChanged), by user interaction: \(sc.valueChangedByUserInteraction)")
    }
    func CHANGE_SEGMENTED_CONTROL_TINT_COLOR() {
        sc.tintColor = UIColor.msr_randomColor(opaque: true)
        button.msr_setBackgroundImageWithColor(sc.tintColor)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle()
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
}
