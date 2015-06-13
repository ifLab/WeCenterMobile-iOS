//
//  SearchViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    let objectTypes = [Article.self, Question.self, Topic.self, User.self]
    let nibNames = ["ArticleCell", "QuestionCell", "TopicCell", "UserCell"]
    let identifiers = ["ArticleCell", "QuestionCell", "TopicCell", "UserCell"]
    
    var objects: [DataObject] = []
    var keyword: String = ""
    var page = 1
    var shouldReloadAfterLoadingMore = true
    
    lazy var searchBar: UISearchBar = {
        [weak self] in
        let theme = SettingsManager.defaultManager.currentTheme
        let v = UISearchBar()
        v.delegate = self
        v.placeholder = "搜索用户和内容"
        v.barStyle = theme.navigationBarStyle
        return v
    }()
    
    override func loadView() {
        super.loadView()
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List"), style: .Plain, target: self, action: "showSidebar")
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.wc_addLegendHeaderWithRefreshingTarget(self, action: "refresh")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = objects[indexPath.row]
        let index = objectTypes.indexOfObject(object.classForCoder)
        let identifier = identifiers[index]
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        let userButtonAction: Selector = "didPressUserButton:"
        let topicButtonAction: Selector = "didPressTopicButton:"
        let articleButtonAction: Selector = "didPressArticleButton:"
        let questionButtonAction: Selector = "didPressQuestionButton:"
        switch cell {
        case let cell as ArticleCell:
            cell.update(article: object as! Article, updateImage: true)
            cell.userButton.addTarget(self, action: userButtonAction, forControlEvents: .TouchUpInside)
            cell.articleButton.addTarget(self, action: articleButtonAction, forControlEvents: .TouchUpInside)
            break
        case let cell as QuestionCell:
            cell.update(question: object as! Question, updateImage: true)
            cell.userButton.addTarget(self, action: userButtonAction, forControlEvents: .TouchUpInside)
            cell.questionButton.addTarget(self, action: questionButtonAction, forControlEvents: .TouchUpInside)
            break
        case let cell as TopicCell:
            cell.update(topic: object as! Topic, updateImage: true)
            cell.topicButtonA.addTarget(self, action: topicButtonAction, forControlEvents: .TouchUpInside)
            cell.topicButtonB.addTarget(self, action: topicButtonAction, forControlEvents: .TouchUpInside)
            break
        case let cell as UserCell:
            cell.update(user: object as! User, updateImage: true)
            cell.userButtonA.addTarget(self, action: userButtonAction, forControlEvents: .TouchUpInside)
            cell.userButtonB.addTarget(self, action: userButtonAction, forControlEvents: .TouchUpInside)
            break
        default:
            break
        }
        return cell
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
                        self_.tableView.wc_addLegendFooterWithRefreshingTarget(self_, action: "loadMore")
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
}
