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
//    let model = Model(module: "User", bundle: NSBundle.mainBundle())

    var user: User? {
        return appDelegate.currentUser
    }
    var titles = [
        "Home",
        Msr.Data.LocalizedStrings(module: "Discovery", bundle: NSBundle.mainBundle())["Discovery"],
        "Favorite",
        "Bookmark",
        "Message"
    ]
    var viewControllers: [UIViewController] = [
        HomeViewController(statusBarStyle: .Default),
        DiscoveryViewController(),
        HomeViewController(statusBarStyle: .Default),
        HomeViewController(statusBarStyle: .LightContent),
        HomeViewController(statusBarStyle: .Default)
    ]
    override init() {
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
    }
    required init(coder aDecoder: NSCoder!) {
        contentViewController = Msr.UI.NavigationController(rootViewController: viewControllers[0])
        tableView = UITableView(frame: sidebar.contentView.bounds, style: .Grouped)
        super.init(coder: aDecoder)
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
        let identifier = "\(indexPath)"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell.textLabel.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.selectedBackgroundView = UIView(frame: CGRect(origin: CGPointZero, size: cell.bounds.size))
            cell.selectedBackgroundView.backgroundColor = UIColor(white: 1, alpha: 0.1)
            if indexPath.section == 0 {
                cell.imageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: appDelegate.currentUser?.avatarURL)),
                    placeholderImage: nil,
                    success: {
                        request, response, image in
                        cell.imageView.image = image
                        cell.imageView.sizeToFit()
                        cell.imageView.layer.cornerRadius = cell.imageView.bounds.width / 2
                        cell.imageView.layer.masksToBounds = true
                        self.tableView.reloadData()
                        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: false, scrollPosition: .None)
                    }, failure: nil)
                cell.textLabel.text = appDelegate.currentUser?.name
            } else {
                cell.textLabel.text = titles[indexPath.row]
                cell.imageView.image = Msr.UI.RoundedRectangle(
                    color: UIColor(white: 1, alpha: 0.4),
                    size: CGSize(width: 40, height: 40),
                    cornerRadius: (20, 20, 20, 20)).image
                return cell
            }
        }
        return cell
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
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
    func showSidebar() {
        sidebar.show(animated: true, completion: nil)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle()
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
}
