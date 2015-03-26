//
//  UserAskedQuestionListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserAskedQuestionListViewController: UITableViewController {
    
    var user: User! {
        didSet {
            if user != nil {
                let defaultDate = NSDate(timeIntervalSince1970: 0)
                questions = sorted(user.questions) { ($0.date ?? defaultDate).timeIntervalSince1970 >= ($1.date ?? defaultDate).timeIntervalSince1970 }
            }
        }
    }
    var questions: [Question] = []
    var page = 0
    let count = 20
    
    init(user: User) {
        super.init(style: .Plain)
        self.user = user
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        /// @TODO: UITableView customization
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_loadMoreControl = MSRLoadMoreControl()
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
        return min(page * count, questions.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "")
        let question = questions[indexPath.row]
        cell.textLabel!.text = question.title
        cell.detailTextLabel!.text = question.body
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        msr_navigationController!.pushViewController(QuestionViewController(question: questions[indexPath.row]), animated: true)
    }
    
    internal func refresh() {
        user.fetchQuestions(
            page: 1,
            count: count,
            success: {
                self.page = 1
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
        user.fetchQuestions(
            page: page + 1,
            count: count,
            success: {
                self.page += 1
                self.msr_loadMoreControl!.endLoadingMore()
                self.tableView.reloadData()
            },
            failure: {
                error in
                self.msr_loadMoreControl!.endLoadingMore()
                self.tableView.reloadData()
            })
    }
    
}
