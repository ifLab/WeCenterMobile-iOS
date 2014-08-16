//
//  TopicListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicListViewController: UITableViewController {
    var topicList = [Topic]()
    var page = 1
    let count = 20
    var userID: NSNumber! = nil
    init(userID: NSNumber) {
        super.init(style: .Plain)
        self.userID = userID
        tableView.separatorStyle = .None
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        loadMoreControl = Msr.UI.LoadMoreControl()
        loadMoreControl.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
    }
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func viewDidAppear(animated: Bool) {
        refreshControl.beginRefreshing()
        refresh()
    }
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return topicList.count
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return TopicCell(topic: topicList[indexPath.row], reuseIdentifier: "")
    }
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 80
    }
    func refresh() {
        Topic.fetchTopicListByUserID(userID,
            page: 1,
            count: count,
            strategy: .NetworkFirst,
            success: {
                topics in
                self.page = 1
                self.topicList = topics
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                return
            },
            failure: {
                error in
                println(error.userInfo)
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
    }
    func loadMore() {
        Topic.fetchTopicListByUserID(userID,
            page: page + 1,
            count: count,
            strategy: .NetworkFirst,
            success: {
                topics in
                ++self.page
                self.topicList.extend(topics)
                self.loadMoreControl.endLoadingMore()
                self.tableView.reloadData()
                return
            },
            failure: {
                error in
                println(error.userInfo)
                self.loadMoreControl.endLoadingMore()
                self.tableView.reloadData()
            })
    }
}
