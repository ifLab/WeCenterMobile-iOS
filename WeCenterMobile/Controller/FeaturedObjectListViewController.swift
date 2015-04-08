//
//  FeaturedObjectListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

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
        super.init(style: .Plain)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
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
            headerImageView.image = headerImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
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
        if let cell = cell as? FeaturedQuestionAnswerCell {
            cell.questionButton.addTarget(self, action: "pushQuestionViewController:", forControlEvents: .TouchUpInside)
        }
        cell.update(object: object)
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let object = objects[indexPath.row]
        var index = objectTypes.indexOfObject(object.classForCoder)
        if index >= objectTypes.count {
            return 40
        }
        if let o = object as? FeaturedQuestionAnswer {
            index += o.answers.count == 0 ? 1 : 0
        }
        struct _Static {
            static var cells = [String: FeaturedObjectCell]()
            static var id: dispatch_once_t = 0
        }
        dispatch_once(&_Static.id) {
            for nibName in self.nibNames {
                _Static.cells[nibName] = (NSBundle.mainBundle().loadNibNamed(nibName, owner: self.tableView, options: nil).first as! FeaturedObjectCell)
            }
        }
        let cell = _Static.cells[nibNames[index]]!
        cell.update(object: object)
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 1
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let object = objects[indexPath.row]
        var index = objectTypes.indexOfObject(object.classForCoder)
        if index >= objectTypes.count {
            return 40
        }
        if let o = object as? FeaturedQuestionAnswer {
            index += o.answers.count == 0 ? 1 : 0
        }
        return ["FeaturedQuestionAnswerCell": 140, "FeaturedQuestionAnswerCellWithoutAnswer": 70, "FeaturedArticleCell": 70][nibNames[index]]!
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let object = objects[indexPath.row]
        switch object {
        case let o as FeaturedQuestionAnswer:
            msr_navigationController?.pushViewController(QuestionViewController(question: o.question), animated: true)
            break
        case let o as FeaturedArticle:
            break
        default:
            break
        }
    }
    func pushQuestionViewController(sender: UIButton) {
        if let question = sender.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.footer?.endRefreshing()
        FeaturedObject.fetchFeaturedObjects(page: 1, count: count, type: type,
            success: {
                [weak self] objects in
                self?.page = 1
                self?.objects = objects
                self?.tableView.reloadData()
                self?.tableView.header.endRefreshing()
                if self?.tableView.footer == nil {
                    let footer = self!.tableView.addLegendFooterWithRefreshingTarget(self, refreshingAction: "loadMore")
                    footer.textColor = UIColor.whiteColor()
                    footer.automaticallyRefresh = false
                    self?.footerActivityIndicatorView = footer.valueForKey("activityView") as! UIActivityIndicatorView
                    self?.footerActivityIndicatorView.activityIndicatorViewStyle = .White
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
