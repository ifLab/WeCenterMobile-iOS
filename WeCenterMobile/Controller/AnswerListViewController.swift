//
//  AnswerListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/29.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

@objc enum AnswerListType: Int {
    case User = 1
}

class AnswerListViewController: UITableViewController {
    
    let user: User
    let listType: AnswerListType
    var answers = [Answer]()
    var page = 1
    let count = 20
    
    init(user: User) {
        self.user = user
        listType = .User
        super.init(nibName: nil, bundle: nil)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellReuseIdentifier = "AnswerCellWithQuestionTitle"
    let cellNibName = "AnswerCellWithQuestionTitle"
    
    private var headerImageView: UIImageView! // for keeping weak property in header
    private var headerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in header
    private var footerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in footer
    
    override func loadView() {
        super.loadView()
        title = "\(user.name!) 的回答"
        view.backgroundColor = UIColor.msr_materialGray200()
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        let header = tableView.addLegendHeaderWithRefreshingTarget(self, refreshingAction: "refresh")
        header.textColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        headerImageView = header.valueForKey("arrowImage") as! UIImageView
        headerImageView.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        headerImageView.msr_imageRenderingMode = .AlwaysTemplate
        headerActivityIndicatorView = header.valueForKey("activityView") as! UIActivityIndicatorView
        headerActivityIndicatorView.activityIndicatorViewStyle = .Gray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.header.beginRefreshing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! AnswerCellWithQuestionTitle
        cell.update(answer: answers[indexPath.row], updateImage: true)
        cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
        cell.answerButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
        cell.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func didPressQuestionButton(sender: UIButton) {
        if let question = sender.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    
    func didPressAnswerButton(sender: UIButton) {
        if let answer = sender.msr_userInfo as? Answer {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: answer), animated: true)
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
        tableView.footer?.endRefreshing()
        let success: ([Answer]) -> Void = {
            [weak self] answers in
            if let self_ = self {
                self_.page = 1
                self_.answers = answers
                self_.tableView.header.endRefreshing()
                self_.tableView.reloadData()
                if self_.tableView.footer == nil {
                    let footer = self_.tableView.addLegendFooterWithRefreshingTarget(self, refreshingAction: "loadMore")
                    footer.textColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
                    footer.automaticallyRefresh = false
                    self_.footerActivityIndicatorView = footer.valueForKey("activityView") as! UIActivityIndicatorView
                    self_.footerActivityIndicatorView.activityIndicatorViewStyle = .Gray
                }
            }
        }
        let failure: (NSError) -> Void = {
            [weak self] error in
            self?.tableView.header.endRefreshing()
            return
        }
        switch listType {
        case .User:
            user.fetchAnswers(page: 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
    
    internal func loadMore() {
        if tableView.header.isRefreshing() {
            tableView.footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        let success: ([Answer]) -> Void = {
            [weak self] answers in
            if self?.shouldReloadAfterLoadingMore ?? false {
                self?.page = self!.page + 1
                self?.answers.extend(answers)
                self?.tableView.reloadData()
            }
            self?.tableView.footer.endRefreshing()
        }
        let failure: (NSError) -> Void = {
            [weak self] error in
            self?.tableView.footer.endRefreshing()
            return
        }
        switch listType {
        case .User:
            user.fetchAnswers(page: page + 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
}
