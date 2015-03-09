//
//  MainViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/26.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var contentViewController: Msr.UI.NavigationController! = nil
    let sidebar = Msr.UI.Sidebar(width: 200, blurEffectStyle: .Light)
    var tableView: UITableView! = nil
    var user: User? {
        return appDelegate.currentUser
    }
    var titles = [
        "首页", // Needs localization
        "发现",
        "测试",
        "测试",
        "测试"
    ]
    override init() {
        super.init(nibName: nil, bundle: nil)
        contentViewController = Msr.UI.NavigationController(rootViewController: viewControllerAtIndex(0))
        addChildViewController(contentViewController)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: sidebar.contentView.bounds, style: .Grouped)
        view.addSubview(contentViewController.view)
        view.insertSubview(sidebar, aboveSubview: contentViewController.view)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clearColor()
        tableView.separatorStyle = .SingleLineEtched
        tableView.showsVerticalScrollIndicator = false
        sidebar.contentView.addSubview(tableView)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return titles.count
        } else {
            return 1
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "\(indexPath)"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell.textLabel!.textColor = UIColor.blackColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.selectedBackgroundView = UIView(frame: CGRect(origin: CGPointZero, size: cell.bounds.size))
            cell.selectedBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            if indexPath.section == 0 {
                appDelegate.currentUser!.fetchAvatar(
                    success: {
                        let size = CGSize(width: 50, height: 50)
                        cell.imageView!.image = appDelegate.currentUser!.avatar?.msr_imageOfSize(size)
                        cell.imageView!.sizeToFit()
                        cell.imageView!.layer.cornerRadius = cell.imageView!.bounds.width / 2
                        cell.imageView!.layer.masksToBounds = true
                        self.tableView.reloadData()
                        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: false, scrollPosition: .None)
                    },
                    failure: nil)
                cell.textLabel!.text = appDelegate.currentUser?.name
            } else if indexPath.section == 1 {
                cell.imageView!.image = UIImage.msr_circleWithColor(UIColor(white: 0, alpha: 0.2), radius: 20)
                cell.imageView!.tintColor = UIColor.blackColor()
                cell.imageView!.layer.contentsScale = UIScreen.mainScreen().scale
                cell.textLabel!.text = titles[indexPath.row]
            } else {
                cell.textLabel!.text = "注销"
            }
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sidebar.hide(animated: true)
        if indexPath.section == 0 {
            contentViewController.setViewControllers([UserViewController(user: appDelegate.currentUser!)], animated: true)
        } else if indexPath.section == 1 {
            contentViewController.setViewControllers([viewControllerAtIndex(indexPath.row)], animated: true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 60
        }
    }
    var svc: Msr.UI.SegmentedViewController!
    var sc: Msr.UI.SegmentedControl!
    var slider: UISlider!
    var button: UIButton!
    var toolBar: UIToolbar!
    func viewControllerAtIndex(index: Int) -> UIViewController {
        var viewController: UIViewController! = nil
        switch index {
        case 0:
            viewController = HomeViewController(user: appDelegate.currentUser!)
            break
        case 1:
            viewController = DiscoveryViewController()
            break
        case 2:
            viewController = TestViewController(statusBarStyle: .Default)
            break
        case 3:
            viewController = UIViewController()
            slider = UISlider(frame: CGRectZero)
            button = UIButton(frame: CGRectZero)
            toolBar = UIToolbar()
            sc = Msr.UI.SegmentedControl(segments: [
                Msr.UI.SegmentedControl.DefaultSegment(title: "个人收藏", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20))),
                Msr.UI.SegmentedControl.DefaultSegment(title: "最近通话", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20))),
                Msr.UI.SegmentedControl.DefaultSegment(title: "通讯录", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20))),
                Msr.UI.SegmentedControl.DefaultSegment(title: "拨号键盘", image: UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20)))])
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
            button.setBackgroundImage(UIImage.msr_rectangleWithColor(sc.indicator.tintColor, size: CGSize(width: 1, height: 1)), forState: .Normal)
            button.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            button.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
            button.msr_addTopAttachedConstraintToSuperview()
            button.msr_topAttachedConstraint!.constant = 300
            button.msr_addHeightConstraintWithValue(44)
            button.addTarget(self, action: "CHANGE_SEGMENTED_CONTROL_TINT_COLOR", forControlEvents: .TouchUpInside)
            sc.backgroundView = toolBar
            sc.indicator = Msr.UI.UnderlineIndicator()
            break
        case 4:
            var viewControllers = [UIViewController]()
            for i in 1...10 {
                let vc = UIViewController()
                vc.view = UIScrollView()
                (vc.view as! UIScrollView).alwaysBounceVertical = true
                vc.view.backgroundColor = UIColor.msr_randomColor(true)
                vc.title = "第\(i)个"
                viewControllers.append(vc)
            }
            svc = Msr.UI.SegmentedViewController(viewControllers: viewControllers)
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
        sc.insertSegment(Msr.UI.SegmentedControl.DefaultSegment(title: "NEW", image: UIImage.msr_rectangleWithColor(UIColor.purpleColor(), size: CGSize(width: 20, height: 20))), atIndex: sc.numberOfSegments >= 1 ? 1 : 0, animated: true)
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
                vc.view.backgroundColor = UIColor.msr_randomColor(true)
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
        sc.tintColor = UIColor.msr_randomColor(true)
        button.setBackgroundImage(UIImage.msr_rectangleWithColor(sc.tintColor, size: CGSize(width: 1, height: 1)), forState: .Normal)
    }
    func showSidebar() {
        sidebar.show(animated: true)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle()
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
}
