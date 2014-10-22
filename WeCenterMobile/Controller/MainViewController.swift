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
        "Home",
        Msr.Data.LocalizedStrings(module: "Discovery", bundle: NSBundle.mainBundle())["Discovery"],
        "Favorite",
        "Bookmark",
        "Message",
        "TEST VC"
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
            cell.textLabel.textColor = UIColor.blackColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.selectedBackgroundView = UIView(frame: CGRect(origin: CGPointZero, size: cell.bounds.size))
            cell.selectedBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            if indexPath.section == 0 {
                appDelegate.currentUser!.fetchAvatar(
                    success: {
                        cell.imageView.image = appDelegate.currentUser!.avatar
                        cell.imageView.sizeToFit()
                        cell.imageView.layer.cornerRadius = cell.imageView.bounds.width / 2
                        cell.imageView.layer.masksToBounds = true
                        self.tableView.reloadData()
                        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: false, scrollPosition: .None)
                    },
                    failure: nil)
                cell.textLabel.text = appDelegate.currentUser?.name
            } else if indexPath.section == 1 {
                cell.imageView.image = UIImage.circleWithColor(UIColor(white: 0, alpha: 0.2), radius: 20)
                cell.imageView.tintColor = UIColor.blackColor()
                cell.imageView.layer.contentsScale = UIScreen.mainScreen().scale
                cell.textLabel.text = titles[indexPath.row]
            } else {
                cell.textLabel.text = "TEMPORARY_EXIT"
            }
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sidebar.hide(animated: true, completion: nil)
        if indexPath.section == 0 {
            contentViewController.setViewControllers([UserViewController(userID: appDelegate.currentUser!.id)], animated: true, completion: nil)
        } else if indexPath.section == 1 {
            contentViewController.setViewControllers([viewControllerAtIndex(indexPath.row)], animated: true, completion: nil)
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
    func viewControllerAtIndex(index: Int) -> UIViewController {
        var viewController: UIViewController! = nil
        switch index {
        case 0:
            viewController = UIViewController()
            break
        case 1:
            viewController = DiscoveryViewController()
            break
        case 2:
            viewController = UIViewController()
            break
        case 3:
            viewController = UIViewController()
            break
        case 4:
            viewController = UIViewController()
            break
        case 5:
            viewController = HomeViewController(statusBarStyle: .Default)
            break
        default:
            break
        }
        return viewController
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
