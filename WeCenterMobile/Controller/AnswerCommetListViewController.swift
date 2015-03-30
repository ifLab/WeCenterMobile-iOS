//
//  AnswerCommetListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/4.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class AnswerCommentListViewController: UITableViewController {
    private var answer: Answer! {
        didSet {
            if answer != nil {
                let defaultDate = NSDate(timeIntervalSince1970: 0)
                comments = sorted(answer.comments) { ($0.date ?? defaultDate).timeIntervalSince1970 >= ($1.date ?? defaultDate).timeIntervalSince1970 }
            }
        }
    }
    var comments: [AnswerComment] = []
    let cellReuseIdentifier = "CommentCell"
    let cellNibName = "CommentCell"
    var keyboardBar: MSRKeyboardBar!
    let textField = UITextField()
    let publishButton = UIButton()
    init(answer: Answer) {
        super.init(style: .Plain)
        self.answer = answer
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        keyboardBar = MSRKeyboardBar()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .None
        title = "评论"
        let views = ["t": textField, "b": publishButton]
        for (k, v) in views {
            v.setTranslatesAutoresizingMaskIntoConstraints(false)
            keyboardBar.addSubview(v)
        }
        textField.placeholder = "在此处输入评论……"
        textField.borderStyle = .None
        textField.clearButtonMode = .WhileEditing
        publishButton.setTitle("发布", forState: .Normal) // Needs localization
        publishButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        publishButton.msr_setBackgroundImageWithColor(UIColor.msr_materialTeal500())
        publishButton.addTarget(self, action: "publishComment", forControlEvents: .TouchUpInside)
        keyboardBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[t]-5-[b(==75)]|", options: nil, metrics: nil, views: views))
        keyboardBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[t(>=44)]|", options: nil, metrics: nil, views: views))
        keyboardBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[b(>=44)]|", options: nil, metrics: nil, views: views))
        keyboardBar.backgroundColor = UIColor.whiteColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.beginRefreshing()
        refresh()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        msr_navigationWrapperController!.view.addSubview(keyboardBar)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        var cell: CommentCell! = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as? CommentCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(cellNibName, owner: self, options: nil).first as! CommentCell
        }
        cell.update(answerComment: comment)
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let comment = comments[indexPath.row]
        struct _Static {
            static var cell: CommentCell!
            static var id: dispatch_once_t = 0
        }
        dispatch_once(&_Static.id) {
            _Static.cell = NSBundle.mainBundle().loadNibNamed(self.cellNibName, owner: self, options: nil).first as! CommentCell
        }
        let cell = _Static.cell
        cell.update(answerComment: comment)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 1 // the height of separator
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CommentCell
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(
            title: "回复",
            style: .Default) {
                [weak self] action in
                self?.textField.text = "@" + cell.userNameLabel.text! + ":" + self!.textField.text!
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
        alertController.addAction(UIAlertAction(
            title: "复制",
            style: .Default) {
                action in
                UIPasteboard.generalPasteboard().string = cell.bodyLabel.text
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
        alertController.addAction(UIAlertAction(
            title: "取消",
            style: .Cancel) {
                action in
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
        presentViewController(alertController, animated: true, completion: nil)
    }
    internal func publishComment() {
        if answer != nil && !(refreshControl?.refreshing ?? true) {
            AnswerComment.post(
                answerID: answer.id,
                body: textField.text,
                atUserName: nil,
                success: {
                    [weak self] in
                    self?.refreshControl?.beginRefreshing()
                    self?.refresh()
                },
                failure: {
                    [weak self] error in
                    let ac = UIAlertController(title: (error.userInfo?[NSLocalizedDescriptionKey] as? String) ?? "",
                        message: nil,
                        preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                    self?.presentViewController(ac, animated: true, completion: nil)
                })
        }
    }
    func refresh() {
        answer.fetchComments(
            success: {
                [weak self] in
                self?.tableView.reloadData()
                self?.refreshControl!.endRefreshing()
            },
            failure: {
                [weak self] error in
                self?.tableView.reloadData()
                self?.refreshControl!.endRefreshing()
            })
    }
}