//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/24.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit

class HomeViewController: UITableViewController {
    
    let count = 20
    var page = 1
    var shouldReloadAfterLoadingMore = true
    
    let user: User
    var actions = [Action]()
    
    let actionTypes = [AnswerAction.self, QuestionPublishmentAction.self, QuestionFocusingAction.self, AnswerAgreementAction.self, ArticlePublishmentAction.self, ArticleAgreementAction.self]
    let identifiers = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell"]
    let nibNames = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell"]
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var headerImageView: UIImageView! // for keeping weak property in header
    private var headerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in header
    private var footerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in footer
    override func loadView() {
        super.loadView()
        tableView = ButtonTouchesCancelableTableView()
        tableView.delegate = self
        tableView.dataSource = self
        title = "首页" // Needs localization
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List"), style: .Plain, target: self, action: "showSidebar")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Compose"), style: .Plain, target: self, action: "showQuestionPublishmentViewController")
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
// MSR_BEGIN
        let iv = UIImageView(image: UIImage(named: "LoginViewBackground"))
        iv.contentMode = .ScaleAspectFill
        tableView.backgroundView = iv
// MSR_END
//        view.backgroundColor = UIColor.msr_materialBlueGray800()
        tableView.separatorStyle = .None
        tableView.indicatorStyle = .White
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        msr_navigationBar!.barStyle = .Black
        msr_navigationBar!.tintColor = UIColor.whiteColor()
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
        return min(page * count, actions.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let action = actions[indexPath.row]
        let index = actionTypes.indexOfObject(action.classForCoder)
        if index >= identifiers.count {
            return UITableViewCell() // Needs specification
        }
        var cell: ActionCell! = tableView.dequeueReusableCellWithIdentifier(identifiers[index]) as? ActionCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(nibNames[index], owner: self, options: nil).first as! ActionCell
        }
        cell.update(action: action, updateImage: true)
        switch cell {
        case let cell as AnswerActionCell:
            cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            cell.answerButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
            break
        case let cell as QuestionPublishmentActionCell:
            cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            break
        case let cell as QuestionFocusingActionCell:
            cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            break
        case let cell as AnswerAgreementActionCell:
            cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            cell.answerButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
            break
        case let cell as ArticlePublishmentActionCell:
            break
        case let cell as ArticleAgreementActionCell:
            break
        default:
            break
        }
        return cell
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    func showQuestionPublishmentViewController() {
        let vc = NSBundle.mainBundle().loadNibNamed("QuestionPublishmentViewController", owner: self, options: nil).first as! QuestionPublishmentViewController
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func pushUserViewController(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
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
    
    internal func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.footer?.endRefreshing()
        user.fetchRelatedActions(
            page: 1,
            count: count,
            success: {
                [weak self] actions in
                if let self_ = self {
                    self_.page = 1
                    self_.actions = actions
                    self_.tableView.reloadData()
                    self_.tableView.header.endRefreshing()
                    if self_.tableView.footer == nil {
                        let footer = self_.tableView.addLegendFooterWithRefreshingTarget(self, refreshingAction: "loadMore")
                        footer.textColor = UIColor.whiteColor()
                        footer.automaticallyRefresh = false
                        self_.footerActivityIndicatorView = footer.valueForKey("activityView") as! UIActivityIndicatorView
                        self_.footerActivityIndicatorView.activityIndicatorViewStyle = .White
                    }
                }
            },
            failure: {
                [weak self] error in
                self?.tableView.header.endRefreshing()
                return
            })
    }
    
    internal func loadMore() {
        if tableView.header.isRefreshing() {
            tableView.footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        user.fetchRelatedActions(
            page: page + 1,
            count: count,
            success: {
                [weak self] actions in
                if let self_ = self {
                    if self_.shouldReloadAfterLoadingMore ?? false {
                        self_.page = self!.page + 1
                        self_.actions.extend(actions)
                        self_.tableView.reloadData()
                    }
                    self_.tableView.footer.endRefreshing()
                }
            },
            failure: {
                [weak self] error in
                self?.tableView.footer.endRefreshing()
                return
            })
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}