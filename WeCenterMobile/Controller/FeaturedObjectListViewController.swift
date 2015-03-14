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
    var page = 0
    var objects: [FeaturedObject] = []
    let count = 5
    let objectTypes = [FeaturedQuestionAnswer.self, FeaturedArticle.self]
    let identifiers = ["FeaturedQuestionAnswerCell", "FeaturedArticleCell"]
    let nibNames = ["FeaturedQuestionAnswerCell", "FeaturedArticleCell"]
    init(type: FeaturedObjectListType) {
        self.type = type
        super.init(style: .Plain)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        refreshControl!.tintColor = UIColor.whiteColor()
        msr_loadMoreControl = MSRLoadMoreControl()
        msr_loadMoreControl!.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
        tableView.contentInset.top = _MSRSegmentedControlDefaultHeightAtTop + 64 // Thanks to the bad implementation of MSRSegmentedViewController
        tableView.separatorStyle = .None
        tableView.scrollIndicatorInsets.top = tableView.contentInset.top
        view.backgroundColor = UIColor.darkGrayColor()
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
    }
    func segmentedViewControllerDidSelectSelf(segmentedViewController: MSRSegmentedViewController) {
        if firstSelected {
            firstSelected = false
            refreshControl!.beginRefreshing()
            refresh()
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
        let index = objectTypes.indexOfObject(object.classForCoder)
        if index >= objectTypes.count {
            return UITableViewCell() // Needs specification
        }
        var cell: FeaturedObjectCell! = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as? FeaturedObjectCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(nibName, owner: self.tableView, options: nil).first as! FeaturedObjectCell
        }
        cell.update(object: object)
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let object = objects[indexPath.row]
        let index = objectTypes.indexOfObject(object.classForCoder)
        if index >= objectTypes.count {
            return 40
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
    func refresh() {
        FeaturedObject.fetchFeaturedObjects(page: 0, count: count, type: type,
            success: {
                [weak self] objects in
                self?.page = 0
                self?.objects = objects
                self?.tableView.reloadData()
                self?.refreshControl!.endRefreshing()
                return
            },
            failure: {
                [weak self] error in
                self?.tableView.reloadData()
                self?.refreshControl!.endRefreshing()
                return
            })
    }
    func loadMore() {
        FeaturedObject.fetchFeaturedObjects(page: page + 1, count: count, type: type,
            success: {
                [weak self] objects in
                self?.page = self!.page + 1
                self?.objects.extend(objects)
                self?.tableView.reloadData()
                self?.msr_loadMoreControl!.endLoadingMore()
                return
            },
            failure: {
                [weak self] error in
                self?.tableView.reloadData()
                self?.msr_loadMoreControl!.endLoadingMore()
                return
            })
    }
}
