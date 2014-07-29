//
//  MainViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/26.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let contentViewController: Msr.UI.NavigationController
    let sidebar = Msr.UI.Sidebar(width: 200, blurEffectStyle: .Dark)
    let tableView: UITableView
    var user: User? {
        return appDelegate.currentUser
    }
    var titles = [
        "Home",
        "Discovery",
        "Favorite",
        "Bookmark",
        "Message"
    ]
    var viewControllers: [UIViewController] = [
        HomeViewController(statusBarStyle: .Default),
        HomeViewController(statusBarStyle: .LightContent),
        HomeViewController(statusBarStyle: .Default),
        HomeViewController(statusBarStyle: .LightContent),
        HomeViewController(statusBarStyle: .Default)
    ]
    init() {
        contentViewController = Msr.UI.NavigationController(rootViewController: viewControllers[0])
        tableView = UITableView(frame: sidebar.contentView.bounds, style: .Grouped)
        super.init(nibName: nil, bundle: nil)
        addChildViewController(contentViewController)
        view.addSubview(contentViewController.view)
        view.insertSubview(sidebar, aboveSubview: contentViewController.view)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clearColor()
        tableView.separatorStyle = .SingleLineEtched
        sidebar.contentView.addSubview(tableView)
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: false, scrollPosition: .None)
    }
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return titles.count
        }
    }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "")
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = UIView(frame: CGRect(origin: CGPointZero, size: cell.bounds.size))
        cell.selectedBackgroundView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        if indexPath.section == 0 {
            cell.imageView.image = UIImage(named: "Butterfly").imageOfSize(CGSize(width: 50, height: 50))
            cell.imageView.layer.cornerRadius = 25
            cell.imageView.layer.masksToBounds = true
        } else {
            cell.textLabel.text = titles[indexPath.row]
            cell.imageView.image = Msr.UI.RoundedRectangle(
                color: UIColor(white: 1, alpha: 0.4),
                size: CGSize(width: 40, height: 40),
                cornerRadius: (20, 20, 20, 20)).image
            cell.imageView.layer.contentsScale = UIScreen.mainScreen().scale
            return cell
        }
        return cell
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        sidebar.hide(animated: true, completion: nil)
        if indexPath.section == 0 {
            contentViewController.setViewControllers([UserMainViewController()], animated: true, completion: nil)
        } else {
            contentViewController.setViewControllers([viewControllers[indexPath.row]], animated: true, completion: nil)
        }
    }
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 60
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle()
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
}
