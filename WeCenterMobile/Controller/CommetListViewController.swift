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

enum AnswerOrArticle {
    case Answer_(Answer)
    case Article_(Article)
}

class CommentListViewController: UITableViewController {
    private var answerOrArticle: AnswerOrArticle
    var comments = [Comment]()
    let cellReuseIdentifier = "CommentCell"
    let cellNibName = "CommentCell"
    var keyboardBar: MSRKeyboardBar!
    let textField = UITextField()
    let publishButton = UIButton()
    init(answer: Answer) {
        self.answerOrArticle = .Answer_(answer)
        super.init(nibName: nil, bundle: nil)
    }
    init(article: Article) {
        self.answerOrArticle = .Article_(article)
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        tableView = ButtonTouchesCancelableTableView()
        tableView.delegate = self
        tableView.dataSource = self
        keyboardBar = MSRKeyboardBar()
        refreshControl = UIRefreshControl()
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .None
        tableView.contentInset.bottom = 50
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.keyboardDismissMode = .OnDrag
        tableView.backgroundColor = UIColor.msr_materialBlueGray800()
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        tableView.indicatorStyle = .White
        msr_navigationBar!.barStyle = .Black
        msr_navigationBar!.tintColor = UIColor.whiteColor()
        title = "评论"
        let views = ["t": textField, "b": publishButton]
        for (k, v) in views {
            v.setTranslatesAutoresizingMaskIntoConstraints(false)
            keyboardBar.addSubview(v)
        }
        textField.keyboardAppearance = .Dark
        textField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        textField.attributedPlaceholder = NSAttributedString(string: "在此处输入评论……", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor()])
        textField.borderStyle = .None
        textField.clearButtonMode = .WhileEditing
        publishButton.setTitle("发布", forState: .Normal) // Needs localization
        publishButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.87), forState: .Normal)
        publishButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.2), forState: .Normal)
        publishButton.msr_setBackgroundImageWithColor(UIColor.whiteColor().colorWithAlphaComponent(0.2), forState: .Highlighted)
        publishButton.addTarget(self, action: "publishComment", forControlEvents: .TouchUpInside)
        keyboardBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[t]-5-[b(==75)]|", options: nil, metrics: nil, views: views))
        keyboardBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[t(>=50)]|", options: nil, metrics: nil, views: views))
        keyboardBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[b(>=50)]|", options: nil, metrics: nil, views: views))
        keyboardBar.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
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
        return cell
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
        if !(refreshControl?.refreshing ?? true) {
            textField.resignFirstResponder()
            let manager = DataManager.temporaryManager!
            let success: () -> Void = {
                [weak self] in
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccessWithStatus("已发布", maskType: .Gradient)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                    SVProgressHUD.dismiss()
                }
                self?.textField.text = ""
                self?.refreshControl?.beginRefreshing()
                self?.refresh()
            }
            let failare: (NSError) -> Void = {
                [weak self] error in
                SVProgressHUD.dismiss()
                let ac = UIAlertController(title: (error.userInfo?[NSLocalizedDescriptionKey] as? String) ?? "",
                    message: nil,
                    preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self?.presentViewController(ac, animated: true, completion: nil)
            }
            switch answerOrArticle {
            case .Answer_(let answer):
                let comment = manager.create("AnswerComment") as! AnswerComment
                comment.answer = (manager.create("Answer") as! Answer)
                comment.answer!.id = answer.id
                comment.body = textField.text
                SVProgressHUD.showWithMaskType(.Gradient)
                comment.post(success: success, failure: failare)
                break
            case .Article_(let article):
                break
            default:
                break
            }
        }
    }
    func refresh() {
        let success: ([Comment]) -> Void = {
            [weak self] comments in
            self?.comments = comments
            self?.tableView.reloadData()
            self?.refreshControl!.endRefreshing()
        }
        let failure: (NSError) -> Void = {
            [weak self] error in
            self?.tableView.reloadData()
            self?.refreshControl!.endRefreshing()
        }
        switch answerOrArticle {
        case .Answer_(let answer):
            answer.fetchComments(
                success: { success($0) },
                failure: failure)
            break
        case .Article_(let article):
            article.fetchComments(
                success: { success($0) },
                failure: failure)
            break
        default:
            break
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}