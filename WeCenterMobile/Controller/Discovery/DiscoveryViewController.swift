//
//  DiscoveryViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/30.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

// Msr.UI.SegmentedViewController(
//     frame: UIScreen.mainScreen().bounds,
//     toolBarStyle: .Black,
//     viewControllers: [
//         DiscoveryViewController(),
//         DiscoveryViewController(),
//         DiscoveryViewController(),
//         DiscoveryViewController()
//     ])

class DiscoveryViewController: Msr.UI.SegmentedViewController {
    
    init() {
        super.init(
            frame: UIScreen.mainScreen().bounds,
            toolBarStyle: .Black,
            viewControllers: [
                ActivityListViewController(listType: .Hot),
                ActivityListViewController(listType: .New),
                ActivityListViewController(listType: .Unanswered)
            ])
        title = DiscoveryStrings["Discovery"]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List-Dots"), style: .Bordered, target: self, action: "showSidebar")
    }
    
    func refresh() {
        (viewControllers[segmentedControl.selectedSegmentIndex] as ActivityListViewController).refresh()
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.show(animated: true, completion: nil)
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}

class ActivityListViewController: UITableViewController {
    var activityList = [Activity]()
    let listType: Activity.ListType!
    init(listType: Activity.ListType) {
        super.init(style: .Plain)
        self.listType = listType
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        tableView.contentInset.bottom += 10
        switch listType {
        case .Hot:
            title = DiscoveryStrings["Hot"]
            break
        case .New:
            title = DiscoveryStrings["New"]
            break
        case .Unanswered:
            title = DiscoveryStrings["Unanswered"]
            break
        default:
            break
        }
    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        refresh()
    }
    override func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return ActivityCell(activity: activityList[indexPath.row], width: tableView.bounds.width, autoLoadingAvatar: false, reuseIdentifier: nil).bounds.height
    }
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return ActivityCell(activity: activityList[indexPath.row], width: tableView.bounds.width, autoLoadingAvatar: true, reuseIdentifier: nil)
    }
    func pushDetailViewController() {
        msrNavigationController.pushViewController(HomeViewController(statusBarStyle: .LightContent), animated: true, completion: nil)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    func refresh() {
        Activity.fetchActivityList(
            count: 20,
            page: 1,
            dayCount: 30,
            recommended: false,
            type: listType,
            success: {
                activityList in
                self.activityList = activityList
                self.tableView.reloadData()
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
            },
            failure: nil)
    }
}
