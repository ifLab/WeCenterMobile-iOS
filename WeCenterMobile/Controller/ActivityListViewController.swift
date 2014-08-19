//
//  ActivityListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/11.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class ActivityListViewController: UITableViewController {
    var activityList = [Activity]()
    var listType: Activity.ListType? = nil
    var page = 1
    init(listType: Activity.ListType) {
        super.init(style: .Plain)
        self.listType = listType
        tableView.separatorStyle = .None
        tableView.contentInset.bottom += 10
        tableView.backgroundColor = UIColor.whiteColor() // %+0xe0e0e0
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msrLoadMoreControl = Msr.UI.LoadMoreControl()
        msrLoadMoreControl.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
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
    func loadMore() {
        Activity.fetchActivityList(
            count: 20,
            page: self.page + 1,
            dayCount: 30,
            recommended: false,
            type: self.listType!,
            success: {
                activityList in
                ++self.page
                self.activityList.extend(activityList)
                self.msrLoadMoreControl.endLoadingMore()
                self.tableView.reloadData()
            },
            failure: {
                error in
                self.msrLoadMoreControl.endLoadingMore()
                self.tableView.reloadData()
        })
    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        refresh()
    }
    override func viewWillAppear(animated: Bool) {
        msrNavigationBar?.barTintColor = UIColor.paperColorGray300()
        msrNavigationBar?.translucent = false
        msrNavigationBar?.tintColor = UIColor.paperColorGray800()
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
        let activity = activityList[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(activity.title) as? ActivityCell
        if cell == nil {
            cell = ActivityCell(activity: activity, width: tableView.bounds.width, autoLoadingAvatar: true, reuseIdentifier: activity.title)
        }
        if let questionActivity = activity as? QuestionActivity {
            cell!.answerUserAvatarButton.addTarget(self, action: "pushUserViewControllerMatchedToUserAvatarButton:", forControlEvents: .TouchUpInside)
        }
        return cell
    }
    func pushUserViewControllerMatchedToUserAvatarButton(userAvatarButton: UIButton) {
        msrNavigationController!.pushViewController(UserViewController(userID: userAvatarButton.tag), animated: true, completion: nil)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    func refresh() {
        Activity.fetchActivityList(
            count: 20,
            page: 1,
            dayCount: 30,
            recommended: false,
            type: listType!,
            success: {
                activityList in
                self.page = 1
                self.activityList = activityList
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            },
            failure: nil)
    }
}
