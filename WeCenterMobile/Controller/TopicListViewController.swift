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
    private var headerImageView: UIImageView! // for keeping weak property in header
    private var headerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in header
    private var footerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in footer
    let cellNibName = "TopicCell"
    let cellReuseIdentifier = "TopicCell"
    override func loadView() {
        super.loadView()
        tableView = ButtonTouchesCancelableTableView()
        tableView.delegate = self
        tableView.dataSource = self
        title = listType == .User ? "\(user!.name!) 关注的话题" : "话题"
        view.backgroundColor = UIColor.msr_materialBlueGray800()
        tableView.separatorStyle = .None
        tableView.indicatorStyle = .White
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        if listType != .Static {
            let header = tableView.addLegendHeaderWithRefreshingTarget(self, refreshingAction: "refresh")
            header.textColor = UIColor.whiteColor()
            headerImageView = header.valueForKey("arrowImage") as! UIImageView
            headerImageView.tintColor = UIColor.whiteColor()
            headerImageView.image = headerImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
            headerActivityIndicatorView = header.valueForKey("activityView") as! UIActivityIndicatorView
            headerActivityIndicatorView.activityIndicatorViewStyle = .White
        }
        msr_navigationBar!.barStyle = .Black
        msr_navigationBar!.tintColor = UIColor.whiteColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if listType == .User {
            tableView.header.beginRefreshing()
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
        cell.update(topic: topics[indexPath.row], updateImage: true)
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        msr_navigationController!.pushViewController(TopicViewController(topic: topics[indexPath.row]), animated: true)
    }
    var shouldReloadAfterLoadingMore = true
    func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.footer?.endRefreshing()
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
                        self_.tableView.header.endRefreshing()
                        if self_.tableView.footer == nil {
                            let footer = self_.tableView.addLegendFooterWithRefreshingTarget(self_, refreshingAction: "loadMore")
                            footer.textColor = UIColor.whiteColor()
                            footer.automaticallyRefresh = false
                            self_.footerActivityIndicatorView = footer.valueForKey("activityView") as! UIActivityIndicatorView
                            self_.footerActivityIndicatorView.activityIndicatorViewStyle = .White
                        }
                    }
                    return
                },
                failure: {
                    [weak self] error in
                    self?.tableView.header.endRefreshing()
                    return
                })
            break
        default:
            break
        }
    }
    func loadMore() {
        if tableView.header.isRefreshing() {
            tableView.footer!.endRefreshing()
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
                    if self?.shouldReloadAfterLoadingMore ?? false {
                        self?.page = self!.page + 1
                        self?.topics.extend(topics)
                        self?.tableView.reloadData()
                    }
                    self?.tableView.footer.endRefreshing()
                    return
                },
                failure: {
                    [weak self] error in
                    self?.tableView.footer.endRefreshing()
                    return
                })
            break
        default:
            break
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
