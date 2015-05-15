//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/24.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit

@objc protocol ActionCellProtocol {
    optional var userButton: UIButton! { get }
    optional var questionButton: UIButton! { get }
    optional var answerButton: UIButton! { get }
    optional var articleButton: UIButton! { get }
    func update(#action: Action, updateImage: Bool)
}

@objc protocol TableViewCellProtocol {}
extension UITableViewCell: TableViewCellProtocol {}

typealias ActionCell = protocol<ActionCellProtocol, TableViewCellProtocol>

extension AnswerActionCell: ActionCellProtocol {}
extension QuestionPublishmentActionCell: ActionCellProtocol {}
extension QuestionFocusingActionCell: ActionCellProtocol {}
extension AnswerAgreementActionCell: ActionCellProtocol {}
extension ArticlePublishmentActionCell: ActionCellProtocol {}
extension ArticleAgreementActionCell: ActionCellProtocol {}

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
        title = "首页" // Needs localization
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List"), style: .Plain, target: self, action: "showSidebar")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Compose"), style: .Plain, target: self, action: "didPressPublishButton")
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
        view.backgroundColor = UIColor.msr_materialGray200()
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        msr_navigationBar!.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
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
        return min(page * count, actions.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let action = actions[indexPath.row]
        let index = actionTypes.indexOfObject(action.classForCoder)
        if index >= identifiers.count {
            return UITableViewCell() // Needs specification
        }
        var cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! ActionCell
        cell.update(action: action, updateImage: true)
        cell.userButton?.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        cell.questionButton?.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
        cell.answerButton?.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
        cell.articleButton?.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
        return cell as! UITableViewCell
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    func didPressPublishButton() {
        let ac = UIAlertController(title: "发布什么？", message: "选择发布的内容种类。", preferredStyle: .ActionSheet)
        let presentPublishmentViewController: (String, PublishmentViewControllerPresentable) -> Void = {
            [weak self] title, object in
            let vc = NSBundle.mainBundle().loadNibNamed("PublishmentViewControllerA", owner: self, options: nil).first as! PublishmentViewController
            vc.dataObject = object
            vc.headerLabel.text = title
            self?.presentViewController(vc, animated: true, completion: nil)
        }
        ac.addAction(UIAlertAction(title: "问题", style: .Default) {
            action in
            presentPublishmentViewController("发布问题", Question.temporaryObject())
        })
        ac.addAction(UIAlertAction(title: "文章", style: .Default) {
            action in
            presentPublishmentViewController("发布文章", Article.temporaryObject())
        })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func didPressUserButton(sender: UIButton) {
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
    
    func didPressArticleButton(sender: UIButton) {
        if let article = sender.msr_userInfo as? Article {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: article), animated: true)
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
                        footer.textColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
                        footer.automaticallyRefresh = false
                        self_.footerActivityIndicatorView = footer.valueForKey("activityView") as! UIActivityIndicatorView
                        self_.footerActivityIndicatorView.activityIndicatorViewStyle = .Gray
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
        return .Default
    }
}