//
//  HotTopicListViewController.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 15/12/9.
//  Copyright © 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit

class HotTopicListViewController: UITableViewController {
    var type: TopicObjectListType
    var firstSelected = true
    var page = 1
    var topics = [Topic]()
    var shouldReloadAfterLoadingMore = true
    let count = 20
    let objectTypes: [FeaturedObject.Type] = [FeaturedQuestionAnswer.self, FeaturedQuestionAnswer.self, FeaturedArticle.self]
    let cellReuseIdentifier = "TopicCell"
    let cellNibName = "TopicCell"
    init(type: TopicObjectListType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = UIColor.clearColor()
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header.beginRefreshing()
    }
    func segmentedViewControllerDidSelectSelf(segmentedViewController: MSRSegmentedViewController) {
        if firstSelected {
            firstSelected = false
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
    func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.mj_footer?.endRefreshing()
        if type == .Focus {
            let user = User.currentUser!
            user.fetchTopics(
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
        } else {
            Topic.fetchHotTopic(page: 1, count: count, type: type,
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
        }
    }
    func loadMore() {
        if tableView.mj_header.isRefreshing() {
            tableView.mj_footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        if type == .Focus {
            let user = User.currentUser!
            user.fetchTopics(
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
        } else {
            Topic.fetchHotTopic(page: page + 1, count: count, type: type,
                success: {
                    [weak self] topics in
                    if let self_ = self {
                        if self_.shouldReloadAfterLoadingMore {
                            ++self_.page
                            self_.topics.appendContentsOf(topics)
                            self_.tableView.reloadData()
                            self_.tableView.mj_footer.endRefreshing()
                        }
                    }
                    return
                },
                failure: {
                    [weak self] error in
                    self?.tableView.mj_header.endRefreshing()
                    return
                })
        }
    }
}
