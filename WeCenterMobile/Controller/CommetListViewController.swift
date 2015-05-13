//
//  CommetListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/4.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import MJRefresh
import SVProgressHUD
import UIKit

protocol CommentListViewControllerPresentable {
    var commentsForCommentListViewController: Set<Comment> { get }
    func fetchCommentsForCommentListViewController(#success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?)
    func temporaryComment() -> Comment
}

extension Answer: CommentListViewControllerPresentable {
    var commentsForCommentListViewController: Set<Comment> { return comments }
    func fetchCommentsForCommentListViewController(#success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?) {
        fetchComments(success: { success?($0) }, failure: failure)
    }
    func temporaryComment() -> Comment {
        let c = AnswerComment.temporaryObject() // manager.create("AnswerComment") as! AnswerComment
        c.answer = Answer.temporaryObject()
        c.answer!.id = id
        return c
    }
}

extension Article: CommentListViewControllerPresentable {
    var commentsForCommentListViewController: Set<Comment> { return comments }
    func fetchCommentsForCommentListViewController(#success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?) {
        fetchComments(success: { success?($0) }, failure: failure)
    }
    func temporaryComment() -> Comment {
        let c = ArticleComment.temporaryObject()
        c.article = Article.temporaryObject()
        c.article!.id = id
        return c
    }
}

class CommentListViewController: UITableViewController {
    var dataObject: CommentListViewControllerPresentable
    var comments = [Comment]()
    let cellReuseIdentifier = "CommentCell"
    let cellNibName = "CommentCell"
    let keyboardBar = KeyboardBar()
    init(dataObject: CommentListViewControllerPresentable) {
        self.dataObject = dataObject
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        title = "评论"
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView = ButtonTouchesCancelableTableView()
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .None
        tableView.contentInset.bottom = 50
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.keyboardDismissMode = .OnDrag
        tableView.backgroundColor = UIColor.msr_materialGray200()
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        msr_navigationBar!.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        keyboardBar.userAtView.removeButton.addTarget(self, action: "removeAtUser", forControlEvents: .TouchUpInside)
        keyboardBar.publishButton.addTarget(self, action: "publishComment", forControlEvents: .TouchUpInside)
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
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CommentCell
        cell.update(comment: comment, updateImage: true)
        cell.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        cell.commentButton.addTarget(self, action: "didPressCommentButton:", forControlEvents: .TouchUpInside)
        return cell
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    func didPressCommentButton(sender: UIButton) {
        if let comment = sender.msr_userInfo as? Comment {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertController.addAction(UIAlertAction(
                title: "回复",
                style: .Default) {
                    [weak self] action in
                    if comment.user != nil {
                        let user = DataManager.temporaryManager!.create("User") as! User
                        user.id = comment.user!.id
                        user.name = comment.user!.name
                        self?.keyboardBar.userAtView.msr_userInfo = user
                        self?.animate() {
                            self?.keyboardBar.userAtView.userNameLabel.text = user.name
                            self?.keyboardBar.userAtView.hidden = false
                        }
                    }
                    return
                })
            alertController.addAction(UIAlertAction(
                title: "复制",
                style: .Default) {
                    action in
                    UIPasteboard.generalPasteboard().string = comment.body
                    return
                })
            alertController.addAction(UIAlertAction(
                title: "取消",
                style: .Cancel,
                handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    internal func publishComment() {
        if !(refreshControl?.refreshing ?? true) {
            keyboardBar.textField.resignFirstResponder()
            let comment = dataObject.temporaryComment()
            comment.body = keyboardBar.textField.text
            comment.atUser = keyboardBar.userAtView.msr_userInfo as? User
            SVProgressHUD.showWithMaskType(.Gradient)
            comment.post(
                success: {
                    [weak self] in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccessWithStatus("已发布", maskType: .Gradient)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                        SVProgressHUD.dismiss()
                    }
                    self?.keyboardBar.textField.text = ""
                    self?.removeAtUser()
                    self?.refreshControl?.beginRefreshing()
                    self?.refresh()
                },
                failure: {
                    [weak self] error in
                    SVProgressHUD.dismiss()
                    let ac = UIAlertController(title: (error.userInfo?[NSLocalizedDescriptionKey] as? String) ?? "",
                        message: nil,
                        preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                    self?.presentViewController(ac, animated: true, completion: nil)
                })
        }
    }
    func refresh() {
        dataObject.fetchCommentsForCommentListViewController(
            success: {
            [weak self] comments in
            self?.comments = comments
            self?.tableView.reloadData()
            self?.refreshControl!.endRefreshing()
        }, failure: {
            [weak self] error in
            self?.tableView.reloadData()
            self?.refreshControl!.endRefreshing()
        })
    }
    func removeAtUser() {
        keyboardBar.userAtView.msr_userInfo = nil
        animate() {
            [weak self] in
            self?.keyboardBar.userAtView.hidden = true
            self?.keyboardBar.userAtView.userNameLabel.text = ""
        }
    }
    func animate(animations: (() -> Void)) {
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.7,
            options: .BeginFromCurrentState,
            animations: animations,
            completion: nil)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}
