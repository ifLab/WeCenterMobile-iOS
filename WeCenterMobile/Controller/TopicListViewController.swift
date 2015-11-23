//
//  TopicListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/16.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import MJRefresh
import UIKit

@objc enum TopicListType: Int {
    case User
    case Static
}

class TopicListViewController: UITableViewController {
    var page = 1
    let count = 10
    var user: User? = nil
    var topics = [Topic]()
    var listType: TopicListType
    init(topics: [Topic]) {
        self.topics = topics
        self.listType = .Static
        super.init(nibName: nil, bundle: nil)
    }
    init(user: User) {
        self.user = user
        self.listType = .User
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let cellNibName = "TopicCell"
    let cellReuseIdentifier = "TopicCell"
    override func loadView() {
        super.loadView()
        title = listType == .User ? "\(user!.name!) 关注的话题" : "话题"
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        if listType != .Static {
            tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if listType == .User {
            tableView.mj_header.beginRefreshing()
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TopicCell
        cell.update(topic: topics[indexPath.row])
        cell.topicButtonA.addTarget(self, action: "didPressTopicButton:", forControlEvents: .TouchUpInside)
        cell.topicButtonB.addTarget(self, action: "didPressTopicButton:", forControlEvents: .TouchUpInside)
        return cell
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func didPressTopicButton(sender: UIButton) {
        if let topic = sender.msr_userInfo as? Topic {
            msr_navigationController!.pushViewController(TopicViewController(topic: topic), animated: true)
        }
    }
    var shouldReloadAfterLoadingMore = true
    func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.mj_footer?.endRefreshing()
        switch listType {
        case .User:
            user!.fetchTopics(
                page: 1,
                count: count,
                success: {
                    [weak self] topics in
                    if let self_ = self {
                        self_.page = 1
                        self_.topics = topics
                        self_.tableView.reloadData()
                        self_.tableView.mj_header.endRefreshing()
                        if self_.tableView.mj_footer == nil {
                            self_.tableView.wc_addRefreshingFooterWithTarget(self_, action: "loadMore")
                        }
                    }
                    return
                },
                failure: {
                    [weak self] error in
                    self?.tableView.mj_header.endRefreshing()
                    return
                })
            break
        default:
            break
        }
    }
    func loadMore() {
        if tableView.mj_header.isRefreshing() {
            tableView.mj_footer!.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        switch listType {
        case .User:
            user!.fetchTopics(
                page: page + 1,
                count: count,
                success: {
                    [weak self] topics in
                    if let self_ = self {
                        if self_.shouldReloadAfterLoadingMore {
                            ++self_.page
                            self_.topics.appendContentsOf(topics)
                            self_.tableView.reloadData()
                        }
                        self_.tableView.mj_footer.endRefreshing()
                    }
                    return
                },
                failure: {
                    [weak self] error in
                    self?.tableView.mj_footer.endRefreshing()
                    return
                })
            break
        default:
            break
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
}
