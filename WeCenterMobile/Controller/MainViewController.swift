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
    var sc: Msr.UI.SegmentedControl!
    var slider: UISlider!
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
            sc = Msr.UI.SegmentedControl(views: [
                generateLabelWithText("A"),
                generateLabelWithText("B"),
                generateLabelWithText("C")])
            sc.frame = CGRect(x: 0, y: 100, width: 0, height: 0)
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ADD", style: .Plain, target: self, action: "ADD_NEW_LABEL")
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "REMOVE", style: .Plain, target: self, action: "REMOVE_LABEL")
            viewController.view.addSubview(sc)
            viewController.view.addSubview(slider)
            sc.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            sc.msr_addHorizontalExpandingConstraintsToSuperview()
            sc.msr_addHeightConstraintWithValue(50)
            sc.addTarget(self, action: "SEGMENT_VALUE_DID_CHANGED", forControlEvents: .ValueChanged)
            slider.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            slider.msr_addHorizontalExpandingConstraintsToSuperview()
            slider.msr_addTopAttachedConstraintToSuperview()
            slider.msr_topAttachedConstraint!.constant = 200
            slider.addTarget(self, action: "CHANGE_INDICATOR_POSITION", forControlEvents: .ValueChanged)
            break
        default:
            break
        }
        return viewController
    }
    let generateLabelWithText = {
        (text: String) -> UILabel in
        let label = UILabel()
        label.text = text
        label.bounds.size = CGSize(width: 80, height: 32)
        label.backgroundColor = UIColor.msr_randomColor(true).colorWithAlphaComponent(0.2)
        label.textAlignment = .Center
        return label
    }
    func ADD_NEW_LABEL() {
        sc.insertSegmentWithView(generateLabelWithText("new"), atIndex: sc.numberOfSegments > 0 ? 1 : 0, animated: true)
    }
    func REMOVE_LABEL() {
        sc.removeSegmentAtIndex(sc.numberOfSegments > 1 ? 1 : 0, animated: true)
    }
    func CHANGE_INDICATOR_POSITION() {
        sc.setIndicatorPosition(CGFloat(slider.value) * CGFloat(sc.numberOfSegments - 1), animated: true)
    }
    func SEGMENT_VALUE_DID_CHANGED() {
        println(sc.selectedSegmentIndex)
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
