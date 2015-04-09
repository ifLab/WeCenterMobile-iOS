//
//  UserTopicListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserTopicListViewController: UITableViewController {
    var user: User
    var topics: [Topic] = []
    var page = 1
    let count = 10
    init(user: User) {
        self.user = user
        super.init(style: .Plain)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_loadMoreControl = MSRLoadMoreControl()
        msr_loadMoreControl!.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
        tableView.separatorStyle = .None
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
        refresh()
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(topics.count, page * count)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return TopicCell(topic: topics[indexPath.row], reuseIdentifier: "...")
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        msr_navigationController?.pushViewController(TopicViewController(topic: topics[indexPath.row]), animated: true)
    }
    func refresh() {
        user.fetchTopics(
            page: 1,
            count: count,
            success: {
                topics in
                self.page = 1
                self.topics = topics
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }, failure: {
                error in
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
        })
    }
    func loadMore() {
        user.fetchTopics(
            page: page + 1,
            count: count,
            success: {
                topics in
                ++self.page
                self.topics.extend(topics)
                self.tableView.reloadData()
                self.msr_loadMoreControl?.endLoadingMore()
            },
            failure: {
                error in
                self.tableView.reloadData()
                self.msr_loadMoreControl?.endLoadingMore()
        })
    }
}
