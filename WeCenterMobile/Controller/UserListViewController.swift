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
        case Unknown
    }
    var listType: ListType?
    var ID: NSNumber! = nil
    var user: User! {
        didSet {
            if user != nil {
                switch listType {
                case .Some(.UserFollower):
                    users = sorted(user.followers) { $0.name <= $1.name }
                    break
                case .Some(.UserFollowing):
                    users = sorted(user.followings) { $0.name <= $1.name }
                    break
                default:
                    break
                }
            }
        }
    }
    var users: [User] = []
    var page = 1
    let count = 20
    init(ID: NSNumber, listType: ListType) {
        super.init(style: .Plain)
        self.listType = listType
        self.ID = ID
        user = User.get(ID: ID, error: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        tableView.separatorStyle = .None
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_loadMoreControl = MSRLoadMoreControl()
        msr_loadMoreControl!.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl!.beginRefreshing()
        refresh()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UserCell(user: users[indexPath.row], reuseIdentifier: "")
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        msr_navigationController!.pushViewController(UserViewController(user: users[indexPath.row]), animated: true)
    }
    func refresh() {
        if user == nil {
            User.fetch(
                ID: ID,
                success: {
                    [weak self] user in
                    self?.refresh()
                    return
                },
                failure: nil)
        } else {
            let success: () -> Void = {
                self.page = 1
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
                user?.fetchFollowers(page: 1, count: count, success: success, failure: failure)
                break
            case .UserFollowing:
                user?.fetchFollowings(page: 1, count: count, success: success, failure: failure)
                break
            default:
                break
            }
        }
    }
    func loadMore() {
        let success: () -> Void = {
            ++self.page
            self.msr_loadMoreControl?.endLoadingMore()
            self.tableView.reloadData()
        }
        let failure: (NSError) -> Void = {
            error in
            self.msr_loadMoreControl?.endLoadingMore()
            return
        }
        switch listType! {
        case .UserFollower:
            user?.fetchFollowers(page: page + 1, count: count, success: success, failure: failure)
            break
        case .UserFollowing:
            user?.fetchFollowings(page: page + 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
}
