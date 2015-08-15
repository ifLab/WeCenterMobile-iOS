//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/24.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit

@objc protocol ActionCell: class {
    optional var userButton: UIButton! { get }
    optional var questionButton: UIButton! { get }
    optional var answerButton: UIButton! { get }
    optional var articleButton: UIButton! { get }
    func update(#action: Action)
}

extension AnswerActionCell: ActionCell {}
extension QuestionPublishmentActionCell: ActionCell {}
extension QuestionFocusingActionCell: ActionCell {}
extension AnswerAgreementActionCell: ActionCell {}
extension ArticlePublishmentActionCell: ActionCell {}
extension ArticleAgreementActionCell: ActionCell {}

class HomeViewController: UITableViewController, PublishmentViewControllerDelegate {
    
    let count = 20
    var page = 1
    var shouldReloadAfterLoadingMore = true
    
    let user: User
    var actions = [Action]()
    
    let actionTypes: [Action.Type] = [AnswerAction.self, QuestionPublishmentAction.self, QuestionFocusingAction.self, AnswerAgreementAction.self, ArticlePublishmentAction.self, ArticleAgreementAction.self]
    let identifiers = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell"]
    let nibNames = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell"]
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        title = "首页" // Needs localization
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-Root"), style: .Plain, target: self, action: "showSidebar")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Publishment-Article_Question"), style: .Plain, target: self, action: "didPressPublishButton")
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
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
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
        if let index = find(map(actionTypes) { action.classForCoder === $0 }, true) {
            let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! ActionCell
            cell.update(action: action)
            cell.userButton?.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
            cell.questionButton?.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            cell.answerButton?.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
            cell.articleButton?.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
            return cell as! UITableViewCell
        } else {
            return UITableViewCell() // Needs specification
        }
        
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    func publishmentViewControllerDidSuccessfullyPublishDataObject(publishmentViewController: PublishmentViewController) {
        tableView.header.beginRefreshing()
    }
    
    func didPressPublishButton() {
        let ac = UIAlertController(title: "发布什么？", message: "选择发布的内容种类。", preferredStyle: .ActionSheet)
        let presentPublishmentViewController: (String, PublishmentViewControllerPresentable) -> Void = {
            [weak self] title, object in
            let vc = NSBundle.mainBundle().loadNibNamed("PublishmentViewControllerA", owner: nil, options: nil).first as! PublishmentViewController
            vc.delegate = self
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
                        self_.tableView.wc_addRefreshingFooterWithTarget(self_, action: "loadMore")
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
                    if self_.shouldReloadAfterLoadingMore {
                        ++self_.page
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
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
}