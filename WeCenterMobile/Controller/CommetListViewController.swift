//
//  CommetListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/4.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class CommentListViewController: UITableViewController {
    var answer: Answer!
    init(answer: Answer) {
        super.init(style: .Plain)
        self.answer = answer
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
        return answer.comments.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = BFPaperTableViewCell(style: .Subtitle, reuseIdentifier: "...")
        let comment = answer.comments.allObjects[indexPath.row] as AnswerComment
        cell.textLabel.text = comment.body
        cell.detailTextLabel!.text = comment.atUser?.name ?? ""
        return cell
    }
    func refresh() {
        answer.fetchComments(
            success: {
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            },
            failure: {
                error in
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            })
    }
}