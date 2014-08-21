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
    enum ListType: Int {
        case Normal = 0
        case User = 1
    }
    var listType: ListType! = .Normal
    init(userID: NSNumber) {
        super.init(style: .Plain)
        initialize()
        listType = .User
        self.userID = userID
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
/// @TODO: This version of implementation will cause compiler crash on Xcode 6 Beta 6. Temporarily removed for future use.
//        msr_loadMoreControl = Msr.UI.LoadMoreControl()
//        msr_loadMoreControl.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
    }
    init(topics: [Topic]) {
        super.init(style: .Plain)
        initialize()
        listType = .Normal
        topicList = topics
    }
    func initialize() {
        tableView.separatorStyle = .None
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func viewDidAppear(animated: Bool) {
        refreshControl?.beginRefreshing()
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
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let msr_navigationController = Msr.UI.navigationControllerOfViewController(self)
        msr_navigationController!.pushViewController(TopicViewController(topicID: topicList[indexPath.row].id), animated: true, completion: nil)
    }
    func refresh() {
        switch listType! {
        case .User:
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
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                })
            break
        case .Normal:
            break
        default:
            break
        }
        
    }
/// @TODO: This version of implementation will cause compiler crash on Xcode 6 Beta 6. Temporarily removed for future use.
//    func loadMore() {
//        Topic.fetchTopicListByUserID(userID,
//            page: page + 1,
//            count: count,
//            strategy: .NetworkFirst,
//            success: {
//                topics in
//                ++self.page
//                self.topicList.extend(topics)
//                self.msr_loadMoreControl.endLoadingMore()
//                self.tableView.reloadData()
//                return
//            },
//            failure: {
//                error in
//                self.msr_loadMoreControl.endLoadingMore()
//                self.tableView.reloadData()
//            })
//    }
}
