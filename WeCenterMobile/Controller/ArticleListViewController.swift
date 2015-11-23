//
//  ArticleListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/1.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

@objc enum ArticleListType: Int {
    case User
}

class ArticleListViewController: UITableViewController {
    
    let user: User
    let listType: ArticleListType
    var articles = [Article]()
    var page = 1
    let count = 20
    
    init(user: User) {
        self.user = user
        listType = .User
        super.init(nibName: nil, bundle: nil)
    }
    
    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellReuseIdentifier = "ArticleCell"
    let cellNibName = "ArticleCell"
    
    override func loadView() {
        super.loadView()
        title = "\(user.name!) 的文章"
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header.beginRefreshing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ArticleCell
        cell.update(article: articles[indexPath.row])
        cell.articleButton.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
        cell.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func didPressArticleButton(sender: UIButton) {
        if let article = sender.msr_userInfo as? Article {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: article), animated: true)
        }
    }
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    
    var shouldReloadAfterLoadingMore = true
    
    internal func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.mj_footer?.endRefreshing()
        let success: ([Article]) -> Void = {
            [weak self] articles in
            if let self_ = self {
                self_.page = 1
                self_.articles = articles
                self_.tableView.mj_header.endRefreshing()
                self_.tableView.reloadData()
                if self_.tableView.mj_footer == nil {
                    self_.tableView.wc_addRefreshingFooterWithTarget(self_, action: "loadMore")
                }
            }
        }
        let failure: (NSError) -> Void = {
            [weak self] error in
            self?.tableView.mj_header.endRefreshing()
            return
        }
        switch listType {
        case .User:
            user.fetchArticles(page: 1, count: count, success: success, failure: failure)
            break
        }
    }
    
    internal func loadMore() {
        if tableView.mj_header.isRefreshing() {
            tableView.mj_footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        let success: ([Article]) -> Void = {
            [weak self] articles in
            if let self_ = self {
                if self_.shouldReloadAfterLoadingMore {
                    ++self_.page
                    self_.articles.appendContentsOf(articles)
                    self_.tableView.reloadData()
                }
                self_.tableView.mj_footer.endRefreshing()
            }
        }
        let failure: (NSError) -> Void = {
            [weak self] error in
            self?.tableView.mj_footer.endRefreshing()
            return
        }
        switch listType {
        case .User:
            user.fetchArticles(page: page + 1, count: count, success: success, failure: failure)
            break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
}