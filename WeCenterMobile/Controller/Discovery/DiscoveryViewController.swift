//
//  DiscoveryViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/30.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class DiscoveryViewController: UITableViewController {
    let model = Model(module: "Discovery", bundle: NSBundle.mainBundle())
    let strings = Msr.Data.LocalizedStrings(module: "Discovery", bundle: NSBundle.mainBundle())
    var activityList = [Activity]()
    convenience init() {
        self.init(style: .Plain)
        title = strings["Discovery"]
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    }
    override func viewDidLoad() {
        Activity.fetchActivityList(
            count: 10,
            page: 1,
            dayCount: 30,
            recommended: false,
            type: .New,
            success: {
                activityList in
                self.activityList = activityList
                self.tableView.reloadData()
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Middle, animated: true)
            },
            failure: nil)
    }
    override func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 120
    }
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return ActivityCell(activity: activityList[indexPath.row], size: CGSize(width: tableView.bounds.width, height: 120), reuseIdentifier: nil)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
