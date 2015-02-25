//
//  AnswerCommetListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/4.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class AnswerCommentListViewController: UITableViewController {
    private var answer: Answer!
    let cellReuseIdentifier = "CommentCell"
    let cellNibName = "CommentCell"
    var keyboardBar: Msr.UI.KeyboardBar!
    let textField = UITextField()
    let publishButton = UIButton()
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
        keyboardBar = Msr.UI.KeyboardBar()
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
        publishButton.setBackgroundImage(UIImage.msr_rectangleWithColor(UIColor.materialTeal500(), size: CGSize(width: 1, height: 1)), forState: .Normal)
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
        msr_navigationWrapperView!.addSubview(keyboardBar)
        
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answer.comments.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = answer.comments.allObjects[indexPath.row] as AnswerComment
        var cell: CommentCell! = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as? CommentCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(cellNibName, owner: self, options: nil).first as CommentCell
        }
        cell.update(answerComment: comment)
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let comment = answer.comments.allObjects[indexPath.row] as AnswerComment
        struct _Static {
            static var cell: CommentCell!
            static var id: dispatch_once_t = 0
        }
        dispatch_once(&_Static.id) {
            _Static.cell = NSBundle.mainBundle().loadNibNamed(self.cellNibName, owner: self, options: nil).first as CommentCell
        }
        let cell = _Static.cell
        cell.update(answerComment: comment)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 1 // the height of separator
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as CommentCell
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(
            title: "回复",
            style: .Default) {
                action in
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
    func copyCommentBody() {
        
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        keyboardBar.layoutIfNeeded()
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