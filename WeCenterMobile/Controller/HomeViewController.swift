//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/24.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData

class HomeViewController: UITableViewController {
    
    let count = 10
    var page = 1
    
    var user: User!
    var actions = [Action]()
    
    init(user: User) {
        super.init(style: .Plain)
        self.user = user
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func loadView() {
        super.loadView()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_loadMoreControl = Msr.UI.LoadMoreControl()
        msr_loadMoreControl!.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.beginRefreshing()
        refresh()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(page * count, actions.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "")
        cell.textLabel!.text = actions[indexPath.row].user.name
        return cell
    }
    
    internal func refresh() {
        user.fetchRelatedActions(
            page: 1,
            count: count,
            success: {
                self.page = 1
                self.actions = dataManager.fetchAll("Action", error: nil) as [Action]
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            },
            failure: {
                error in
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            })
    }
    
    internal func loadMore() {
        user.fetchRelatedActions(
            page: page + 1,
            count: count,
            success: {
                ++self.page
                self.actions = dataManager.fetchAll("Action", error: nil) as [Action]
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            },
            failure: {
                error in
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            })
    }
    
}