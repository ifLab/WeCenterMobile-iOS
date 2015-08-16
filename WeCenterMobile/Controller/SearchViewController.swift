//
//  SearchViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

@objc protocol SearchResultCell: class {
    optional var articleButton: UIButton! { get }
    optional var questionButton: UIButton! { get }
    optional var topicButton: UIButton! { get }
    optional var userButton: UIButton! { get }
    func update(#dataObject: DataObject)
}

extension ArticleSearchResultCell: SearchResultCell {}
extension QuestionSearchResultCell: SearchResultCell {}
extension TopicSearchResultCell: SearchResultCell {}
extension UserSearchResultCell: SearchResultCell {}

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    let objectTypes: [DataObject.Type] = [Article.self, Question.self, Topic.self, User.self]
    let nibNames = ["ArticleSearchResultCell", "QuestionSearchResultCell", "TopicSearchResultCell", "UserSearchResultCell"]
    let identifiers = ["ArticleSearchResultCell", "QuestionSearchResultCell", "TopicSearchResultCell", "UserSearchResultCell"]
    
    var objects = [DataObject]()
    var keyword = ""
    var page = 1
    var shouldReloadAfterLoadingMore = true
    
    lazy var searchBar: UISearchBar = {
        [weak self] in
        let theme = SettingsManager.defaultManager.currentTheme
        let v = UISearchBar()
        v.delegate = self
        v.placeholder = "搜索用户和内容"
        v.barStyle = theme.navigationBarStyle
        v.keyboardAppearance = theme.keyboardAppearance
        return v
    }()
    
    override func loadView() {
        super.loadView()
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-Root"), style: .Plain, target: self, action: "showSidebar")
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .OnDrag
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sidebarDidBecomeVisible:", name: SidebarDidBecomeVisibleNotificationName, object: appDelegate.mainViewController.sidebar)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sidebarDidBecomeInvisible:", name: SidebarDidBecomeInvisibleNotificationName, object: appDelegate.mainViewController.sidebar)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = objects[indexPath.row]
        if let index = find(map(objectTypes) { object.classForCoder === $0 }, true) {
            let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! SearchResultCell
            cell.update(dataObject: object)
            cell.articleButton?.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
            cell.questionButton?.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            cell.topicButton?.addTarget(self, action: "didPressTopicButton:", forControlEvents: .TouchUpInside)
            cell.userButton?.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
            return cell as! UITableViewCell
        } else {
            return UITableViewCell() // Needs specification
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let text = searchBar.text ?? ""
        if text != "" {
            keyword = searchBar.text ?? ""
            tableView.header.beginRefreshing()
        }
    }
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    
    func didPressTopicButton(sender: UIButton) {
        if let topic = sender.msr_userInfo as? Topic {
            msr_navigationController!.pushViewController(TopicViewController(topic: topic), animated: true)
        }
    }
    
    func didPressArticleButton(sender: UIButton) {
        if let article = sender.msr_userInfo as? Article {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: article), animated: true)
        }
    }
    
    func didPressQuestionButton(sender: UIButton) {
        if let question = sender.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    
    func refresh() {
        if keyword == "" {
            tableView.header.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = false
        tableView.footer?.endRefreshing()
        DataObject.fetchSearchResultsWithKeyword(keyword,
            type: .All,
            page: 1,
            success: {
                [weak self] objects in
                if let self_ = self {
                    self_.page = 1
                    self_.objects = objects
                    self_.tableView.reloadData()
                    self_.tableView.header.endRefreshing()
                    if self_.tableView.footer == nil {
                        self_.tableView.wc_addRefreshingFooterWithTarget(self_, action: "loadMore")
                    }
                }
                return
            },
            failure: {
                [weak self] error in
                self?.tableView.header.endRefreshing()
                return
            })
    }
    
    func loadMore() {
        if tableView.header.isRefreshing() {
            tableView.footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        DataObject.fetchSearchResultsWithKeyword(keyword,
            type: .All,
            page: page + 1,
            success: {
                [weak self] objects in
                if let self_ = self {
                    if self_.shouldReloadAfterLoadingMore {
                        ++self_.page
                        self_.objects.extend(objects)
                        self_.tableView.reloadData()
                    }
                    self_.tableView.footer.endRefreshing()
                }
                return
            },
            failure: {
                [weak self] error in
                self?.tableView.footer.endRefreshing()
                return
            })
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    func sidebarDidBecomeVisible(notification: NSNotification) {
        if msr_navigationController?.topViewController === self {
            searchBar.endEditing(true)
        }
    }
    
    func sidebarDidBecomeInvisible(notification: NSNotification) {}
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
