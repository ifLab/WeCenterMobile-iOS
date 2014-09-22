//
//  UserListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserListViewController: UITableViewController {
    enum ListType: Int {
        case UserFollowing = 1
        case UserFollower = 2
        case QuestionFollwer = 3
    }
    var listType: ListType! = nil
    var ID: NSNumber! = nil
    var page = 1
    let count = 20
    var userList = [User]()
    init(ID: NSNumber, listType: ListType) {
        super.init(style: .Plain)
        self.listType = listType
        self.ID = ID
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        super.loadView()
        tableView.separatorStyle = .None
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_loadMoreControl = Msr.UI.LoadMoreControl()
        msr_loadMoreControl.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
    }
    override func viewDidAppear(animated: Bool) {
        refreshControl!.beginRefreshing()
        refresh()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UserCell(user: userList[indexPath.row], reuseIdentifier: "")
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        msr_navigationController!.pushViewController(UserViewController(userID: userList[indexPath.row].id), animated: true, completion: nil)
    }
    func refresh() {
        let success: ([User]) -> Void = {
            users in
            self.page = 1
            self.userList = users
            self.refreshControl!.endRefreshing()
            self.tableView.reloadData()
        }
        let failure: (NSError) -> Void = {
            error in
            self.refreshControl!.endRefreshing()
            self.tableView.reloadData()
        }
        switch listType! {
        case .UserFollower:
            User.fetchFollowerListByUserID(ID, strategy: .NetworkFirst, page: 1, count: count, success: success, failure: failure)
            break
        case .UserFollowing:
            User.fetchFollowingListByUserID(ID, strategy: .NetworkFirst, page: 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
    func loadMore() {
        let success: ([User]) -> Void = {
            users in
            ++self.page
            self.userList.extend(users)
            self.msr_loadMoreControl.endLoadingMore()
            self.tableView.reloadData()
        }
        let failure: (NSError) -> Void = {
            error in
            self.msr_loadMoreControl.endLoadingMore()
            self.tableView.reloadData()
        }
        switch listType! {
        case .UserFollower:
            User.fetchFollowerListByUserID(ID, strategy: .NetworkFirst, page: page + 1, count: count, success: success, failure: failure)
            break
        case .UserFollowing:
            User.fetchFollowingListByUserID(ID, strategy: .NetworkFirst, page: page + 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
}
