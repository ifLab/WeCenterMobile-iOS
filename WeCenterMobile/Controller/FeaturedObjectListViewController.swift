//
//  FeaturedObjectListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit

@objc protocol FeaturedObjectCell: class {
    optional var questionUserButton: UIButton! { get }
    optional var questionButton: UIButton! { get }
    optional var answerUserButton: UIButton? { get }
    optional var answerButton: UIButton? { get }
    optional var articleButton: UIButton! { get }
    optional var articleUserButton: UIButton! { get }
    func update(object object: FeaturedObject)
}

extension FeaturedArticleCell: FeaturedObjectCell {}
extension FeaturedQuestionAnswerCell: FeaturedObjectCell {}

class FeaturedObjectListViewController: UITableViewController {
    var type: FeaturedObjectListType
    var firstSelected = true
    var page = 1
    var objects: [FeaturedObject] = []
    var shouldReloadAfterLoadingMore = true
    let count = 10
    let objectTypes: [FeaturedObject.Type] = [FeaturedQuestionAnswer.self, FeaturedQuestionAnswer.self, FeaturedArticle.self]
    let identifiers = ["FeaturedQuestionAnswerCellA", "FeaturedQuestionAnswerCellB", "FeaturedArticleCell"]
    let nibNames = ["FeaturedQuestionAnswerCellA", "FeaturedQuestionAnswerCellB", "FeaturedArticleCell"]
    init(type: FeaturedObjectListType) {
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
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
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
        return objects.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = objects[indexPath.row]
        if var index = (objectTypes.map { object.classForCoder === $0 }).indexOf(true) {
            if let o = object as? FeaturedQuestionAnswer {
                index += o.answers.count == 0 ? 1 : 0
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! FeaturedObjectCell
            cell.answerButton??.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
            cell.answerUserButton??.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
            cell.articleButton?.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
            cell.articleUserButton?.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
            cell.questionButton?.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            cell.questionUserButton?.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
            cell.update(object: object)
            return cell as! UITableViewCell
        } else {
            return UITableViewCell() // Needs specification
        }
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
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
    func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.mj_footer?.endRefreshing()
        FeaturedObject.fetchFeaturedObjects(page: 1, count: count, type: type,
            success: {
                [weak self] objects in
                if let self_ = self {
                    self_.page = 1
                    self_.objects = objects
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
    func loadMore() {
        if tableView.mj_header.isRefreshing() {
            tableView.mj_footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        FeaturedObject.fetchFeaturedObjects(page: page + 1, count: count, type: type,
            success: {
                [weak self] objects in
                if let self_ = self {
                    if self_.shouldReloadAfterLoadingMore {
                        ++self_.page
                        self_.objects.appendContentsOf(objects)
                        self_.tableView.reloadData()
                        self_.tableView.mj_footer.endRefreshing()
                    }
                }
                return
            },
            failure: {
                [weak self] error in
                self?.tableView.mj_footer.endRefreshing()
                return
            })
    }
}
