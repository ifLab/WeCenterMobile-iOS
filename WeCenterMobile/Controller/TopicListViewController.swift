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
    var _user: User? = nil
    var user: User? {
        return User.get(ID: userID, error: nil)
    }
    enum ListType: Int {
        case Normal = 0
        case User = 1
    }
    var listType: ListType! = nil
    init(userID: NSNumber) {
        super.init(style: .Plain)
        listType = .User
        self.userID = userID
    }
    init(topics: [Topic]) {
        super.init(style: .Plain)
        listType = .Normal
        topicList = topics
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        super.loadView()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_loadMoreControl = Msr.UI.LoadMoreControl()
        msr_loadMoreControl.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
        tableView.separatorStyle = .None
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
        refresh()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicList.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return TopicCell(topic: topicList[indexPath.row], reuseIdentifier: "")
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        msr_navigationController!.pushViewController(TopicViewController(topicID: topicList[indexPath.row].id), animated: true, completion: nil)
    }
    func refresh() {
        switch listType! {
        case .User:
            user?.fetchTopics(
                page: 1,
                count: count,
                success: {
                    self.page = 1
                    self.refreshControl!.endRefreshing()
                    self.tableView.reloadData()
                },
                failure: {
                    error in
                    self.refreshControl!.endRefreshing()
                    self.tableView.reloadData()
                })
            break
        case .Normal:
            break
        default:
            break
        }
        
    }
    func loadMore() {
        user?.fetchTopics(
            page: page + 1,
            count: count,
            success: {
                ++self.page
                self.msr_loadMoreControl.endLoadingMore()
                self.tableView.reloadData()
                return
            },
            failure: {
                error in
                self.msr_loadMoreControl.endLoadingMore()
                self.tableView.reloadData()
            })
    }
}
