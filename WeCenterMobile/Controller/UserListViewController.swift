//
//  UserListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import MJRefresh
import UIKit

@objc enum UserListType: Int {
    case UserFollowing = 1
    case UserFollower = 2
    case QuestionFollwer = 3
}

class UserListViewController: UITableViewController {
    let listType: UserListType
    var user: User
    var users: [User] = []
    var page = 1
    let count = 20
    init(user: User, listType: UserListType) {
        self.listType = listType
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let cellNibName = "UserCell"
    let cellReuseIdentifier = "UserCell"
    override func loadView() {
        super.loadView()
        let titles: [UserListType: String] = [
            .UserFollowing: "\(user.name!) 关注的用户",
            .UserFollower: "\(user.name!) 的追随者"]
        self.title = titles[listType]!
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.header.beginRefreshing()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! UserCell
        cell.userButtonA.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        cell.userButtonB.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        cell.update(user: users[indexPath.row])
        return cell
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.footer?.endRefreshing()
        let success: ([User]) -> Void = {
            [weak self] users in
            if let self_ = self {
                self_.page = 1
                self_.users = users
                self_.tableView.header.endRefreshing()
                self_.tableView.reloadData()
                if self_.tableView.footer == nil {
                    self_.tableView.wc_addRefreshingFooterWithTarget(self_, action: "loadMore")
                }
            }
        }
        let failure: (NSError) -> Void = {
            [weak self] error in
            self?.tableView.header.endRefreshing()
            return
        }
        switch listType {
        case .UserFollower:
            user.fetchFollowers(page: 1, count: count, success: success, failure: failure)
            break
        case .UserFollowing:
            user.fetchFollowings(page: 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
    var shouldReloadAfterLoadingMore = true
    func loadMore() {
        if tableView.header.isRefreshing() {
            tableView.footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        let success: ([User]) -> Void = {
            [weak self] users in
            if let self_ = self {
                if self_.shouldReloadAfterLoadingMore {
                    ++self_.page
                    self_.users.extend(users)
                    self_.tableView.reloadData()
                }
                self_.tableView.footer.endRefreshing()
            }
        }
        let failure: (NSError) -> Void = {
            [weak self] error in
            self?.tableView.footer.endRefreshing()
            return
        }
        switch listType {
        case .UserFollower:
            user.fetchFollowers(page: page + 1, count: count, success: success, failure: failure)
            break
        case .UserFollowing:
            user.fetchFollowings(page: page + 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
}
