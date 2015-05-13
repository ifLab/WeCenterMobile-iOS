//
//  FeaturedObjectListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit

class FeaturedObjectListViewController: UITableViewController {
    var type: FeaturedObjectListType
    var firstSelected = true
    var page = 1
    var objects: [FeaturedObject] = []
    var shouldReloadAfterLoadingMore = true
    let count = 10
    let objectTypes = [FeaturedQuestionAnswer.self, FeaturedQuestionAnswer.self, FeaturedArticle.self]
    let identifiers = ["FeaturedQuestionAnswerCell", "FeaturedQuestionAnswerCellWithoutAnswer", "FeaturedArticleCell"]
    let nibNames = ["FeaturedQuestionAnswerCell", "FeaturedQuestionAnswerCellWithoutAnswer", "FeaturedArticleCell"]
    init(type: FeaturedObjectListType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.clearColor()
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.separatorStyle = .None
        tableView.indicatorStyle = .White
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
    }
    private var headerImageView: UIImageView! // for keeping weak property in header
    private var headerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in header
    private var footerActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in footer
    func segmentedViewControllerDidSelectSelf(segmentedViewController: MSRSegmentedViewController) {
        if firstSelected {
            firstSelected = false
            let header = tableView.addLegendHeaderWithRefreshingTarget(self, refreshingAction: "refresh")
            header.textColor = UIColor.whiteColor()
            headerImageView = header.valueForKey("arrowImage") as! UIImageView
            headerImageView.tintColor = UIColor.whiteColor()
            headerImageView.msr_imageRenderingMode = .AlwaysTemplate
            headerActivityIndicatorView = header.valueForKey("activityView") as! UIActivityIndicatorView
            headerActivityIndicatorView.activityIndicatorViewStyle = .White
            tableView.header.beginRefreshing()
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
        var index = objectTypes.indexOfObject(object.classForCoder)
        if index >= objectTypes.count {
            return UITableViewCell() // Needs specification
        }
        if let o = object as? FeaturedQuestionAnswer {
            index += o.answers.count == 0 ? 1 : 0
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! FeaturedObjectCell
        switch cell {
        case let cell as FeaturedQuestionAnswerCellWithoutAnswer:
            cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            break
        case let cell as FeaturedQuestionAnswerCell:
            cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
            cell.answerButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
            break
        case let cell as FeaturedArticleCell:
            cell.articleButton.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
            break
        default:
            break
        }
        cell.update(object: object, updateImage: true)
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
    func didPressArticleButton(sender: UIButton) {
        if let article = sender.msr_userInfo as? Article {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: article), animated: true)
        }
    }
    func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.footer?.endRefreshing()
        FeaturedObject.fetchFeaturedObjects(page: 1, count: count, type: type,
            success: {
                [weak self] objects in
                if let self_ = self {
                    self_.page = 1
                    self_.objects = objects
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
    }
    func loadMore() {
        if tableView.header.isRefreshing() {
            tableView.footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        FeaturedObject.fetchFeaturedObjects(page: page + 1, count: count, type: type,
            success: {
                [weak self] objects in
                if self?.shouldReloadAfterLoadingMore ?? false {
                    self?.page = self!.page + 1
                    self?.objects.extend(objects)
                    self?.tableView.reloadData()
                    self?.tableView.footer.endRefreshing()
                }
                return
            },
            failure: {
                [weak self] error in
                self?.tableView.footer.endRefreshing()
                return
            })
    }
}
