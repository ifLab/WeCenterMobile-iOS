//
//  QuestionListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import MJRefresh
import UIKit


@objc enum QuestionListType: Int {
    case User = 1
}

class QuestionListViewController: UITableViewController {

    let user: User
    let listType: QuestionListType
    var questions = [Question]()
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
    
    let cellReuseIdentifier = "QuestionCell"
    let cellNibName = "QuestionCell"
    
    private var headerImageView: UIImageView! // for keeping weak property in header
    private var headerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in header
    private var footerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in footer
    
    override func loadView() {
        super.loadView()
        title = "\(user.name!) 的提问"
        view.backgroundColor = UIColor.msr_materialBlueGray800()
        msr_navigationBar!.barStyle = .Black
        msr_navigationBar!.tintColor = UIColor.whiteColor()
        tableView.indicatorStyle = .White
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        let header = tableView.addLegendHeaderWithRefreshingTarget(self, refreshingAction: "refresh")
        header.textColor = UIColor.whiteColor()
        headerImageView = header.valueForKey("arrowImage") as! UIImageView
        headerImageView.tintColor = UIColor.whiteColor()
        headerImageView.msr_imageRenderingMode = .AlwaysTemplate
        headerActivityIndicatorView = header.valueForKey("activityView") as! UIActivityIndicatorView
        headerActivityIndicatorView.activityIndicatorViewStyle = .White
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.header.beginRefreshing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! QuestionCell
        cell.update(question: questions[indexPath.row], updateImage: true)
        cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func didPressQuestionButton(button: UIButton) {
        if let question = button.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    
    var shouldReloadAfterLoadingMore = true
    
    internal func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.footer?.endRefreshing()
        let success: ([Question]) -> Void = {
            [weak self] questions in
            if let self_ = self {
                self_.page = 1
                self_.questions = questions
                self_.tableView.header.endRefreshing()
                self_.tableView.reloadData()
                if self_.tableView.footer == nil {
                    let footer = self_.tableView.addLegendFooterWithRefreshingTarget(self_, refreshingAction: "loadMore")
                    footer.textColor = UIColor.whiteColor()
                    footer.automaticallyRefresh = false
                    self_.footerActivityIndicatorView = footer.valueForKey("activityView") as! UIActivityIndicatorView
                    self_.footerActivityIndicatorView.activityIndicatorViewStyle = .White
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
            user.fetchQuestions(page: 1, count: count, success: success, failure: failure)
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
        let success: ([Question]) -> Void = {
            [weak self] questions in
            if self?.shouldReloadAfterLoadingMore ?? false {
                self?.page = self!.page + 1
                self?.questions.extend(questions)
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
            user.fetchQuestions(page: page + 1, count: count, success: success, failure: failure)
            break
        default:
            break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
