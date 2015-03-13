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
        msr_loadMoreControl = MSRLoadMoreControl()
        msr_loadMoreControl!.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
        tableView.contentInset.top = _MSRSegmentedControlDefaultHeightAtTop + 64
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
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "REUSE")
        let object = objects[indexPath.row]
        cell.textLabel!.text = "\(object.date)"
        cell.detailTextLabel!.text = NSStringFromClass(object.dynamicType)
        return cell
    }
    func refresh() {
        FeaturedObject.fetchFeaturedObjects(page: 0, count: count, type: type,
            success: {
                [weak self] objects in
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
        
    }
}
