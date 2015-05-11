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
        vc.view.backgroundColor = UIColor.whiteColor()
        return vc
    }()
    lazy var sidebar: MSRSidebar = {
        let v = MSRSidebar(width: 200, edge: .Left)
        v.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        v.overlay = UIView()
        v.overlay!.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        return v
    }()
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
        NSNotificationCenter.defaultCenter().addObserverForName(CurrentUserPropertyDidChangeNotificationName, object: nil, queue: NSOperationQueue.mainQueue()) {
            [weak self] notification in
            let key = notification.userInfo![KeyUserInfoKey] as! String
            if key == "avatarData" || key == "name" {
                self?.userCell.update(user: User.currentUser, updateImage: key == "avatarData")
            }
            return
        }
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
    func viewControllerAtIndex(index: Int) -> UIViewController {
        var viewController: UIViewController! = nil
        switch index {
        case 0:
            viewController = HomeViewController(user: User.currentUser!)
            break
        case 1:
            viewController = ExploreViewController()
            break
        default:
            break
        }
        return viewController
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle()
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
}
