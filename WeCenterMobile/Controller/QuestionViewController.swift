//
//  QuestionViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionViewController: UITableViewController, DTLazyImageViewDelegate, QuestionBodyCellLinkButtonDelegate {
    
    var question: Question {
        didSet {
            let defaultDate = NSDate(timeIntervalSince1970: 0)
            answers = sorted(question.answers) { ($0.date ?? defaultDate).timeIntervalSince1970 >= ($1.date ?? defaultDate).timeIntervalSince1970 }
        }
    }
    var answers = [Answer]()
    
    let answerCellIdentifier = "AnswerCell"
    let answerCellNibName = "AnswerCell"
    
    lazy var questionHeaderCell: QuestionHeaderCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("QuestionHeaderCell", owner: self?.tableView, options: nil).first as! QuestionHeaderCell
    }()
    lazy var questionTitleCell: QuestionTitleCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("QuestionTitleCell", owner: self?.tableView, options: nil).first as! QuestionTitleCell
    }()
    lazy var questionTagListCell: QuestionTagListCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("QuestionTagListCell", owner: self?.tableView, options: nil).first as! QuestionTagListCell
    }()
    lazy var questionBodyCell: QuestionBodyCell = {
        [weak self] in
        let c = NSBundle.mainBundle().loadNibNamed("QuestionBodyCell", owner: self?.tableView, options: nil).first as! QuestionBodyCell
        c.lazyImageViewDelegate = self
        c.linkButtonDelegate = self
        NSNotificationCenter.defaultCenter().addObserverForName(DTAttributedTextContentViewDidFinishLayoutNotification, object: c.attributedTextContextView, queue: NSOperationQueue.mainQueue()) {
            [weak self] notification in
            self?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
            return
        }
        return c
    }()
    lazy var questionFooterCell: QuestionFooterCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("QuestionFooterCell", owner: self?.tableView, options: nil).first as! QuestionFooterCell
    }()
    lazy var answerAdditionCell: AnswerAdditionCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("AnswerAdditionCell", owner: self?.tableView, options: nil).first as! AnswerAdditionCell
    }()
    
    init(question: Question) {
        self.question = question
        super.init(style: .Plain)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.msr_materialBrown900()
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: answerCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: answerCellIdentifier)
        title = "问题详情" // Needs localization
        msr_navigationBar!.barStyle = .Black
        msr_navigationBar!.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        Question.fetch(
            ID: question.id,
            success: {
                [weak self] question in
                if let self_ = self {
                    self_.question = question
                    self_.tableView.reloadData()
                    if let user = question.user {
                        user.fetchProfile(
                            success: {
                                self_.tableView.reloadData()
                            },
                            failure: {
                                error in
                                NSLog(__FILE__, __FUNCTION__, error)
                                return
                            })
                    }
                }
                return
            }, failure: {
                error in
                NSLog(__FILE__, __FUNCTION__, error)
                return
            })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 1, 1, 1, 1, 1, answers.count][section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            questionHeaderCell.update(user: question.user)
            return questionHeaderCell
        case 1:
            questionTitleCell.update(question: question)
            return questionTitleCell
        case 2:
            questionTagListCell.update(question: question)
            return questionTagListCell
        case 3:
            questionBodyCell.update(question: question)
            return questionBodyCell
        case 4:
            questionFooterCell.update(question: question)
            return questionFooterCell
        case 5:
            return answerAdditionCell
        default:
            let answerCell = tableView.dequeueReusableCellWithIdentifier(answerCellIdentifier, forIndexPath: indexPath) as! AnswerCell
            answerCell.answerButton.addTarget(self, action: "pushAnswerViewController:", forControlEvents: .TouchUpInside)
            answerCell.update(answer: answers[indexPath.row])
            return answerCell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        struct _Static {
            static var id: dispatch_once_t = 0
            static var answerCell: AnswerCell!
        }
        dispatch_once(&_Static.id) {
            [weak self] in
            if let self_ = self {
                _Static.answerCell = NSBundle.mainBundle().loadNibNamed(self_.answerCellNibName, owner: self_.tableView, options: nil).first as! AnswerCell
            }
        }
        switch indexPath.section {
        case 0:
            questionHeaderCell.update(user: question.user)
            return questionHeaderCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 1:
            questionTitleCell.update(question: question)
            return questionTitleCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 2:
            questionTagListCell.update(question: question)
            return questionTagListCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 3:
            questionBodyCell.update(question: question)
            return questionBodyCell.requiredRowHeightInTableView(tableView)
        case 4:
            questionFooterCell.update(question: question)
            return questionFooterCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 5:
            return answerAdditionCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        default:
            _Static.answerCell.update(answer: answers[indexPath.row])
            return _Static.answerCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        }
    }
    
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let predicate = NSPredicate(format: "contentURL == %@", lazyImageView.url)
        let attachments = questionBodyCell.attributedTextContextView.layoutFrame.textAttachmentsWithPredicate(predicate) as? [DTImageTextAttachment] ?? []
        for attachment in attachments {
            attachment.originalSize = size
            let v = questionBodyCell.attributedTextContextView
            let maxWidth = v.bounds.width - v.edgeInsets.left - v.edgeInsets.right
            if size.width > maxWidth {
                let scale = maxWidth / size.width
                attachment.displaySize = CGSize(width: size.width * scale, height: size.height * scale)
            }
        }
        questionBodyCell.attributedTextContextView.layouter = nil
        questionBodyCell.attributedTextContextView.relayoutText()
    }
    
    func didLongPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func didPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func presentLinkAlertControllerWithURL(URL: NSURL) {
        let ac = UIAlertController(title: "链接", message: URL.absoluteString, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "跳转到 Safari", style: .Default) {
            action in
            UIApplication.sharedApplication().openURL(URL)
        })
        ac.addAction(UIAlertAction(title: "复制到剪贴板", style: .Default) {
            [weak self] action in
            UIPasteboard.generalPasteboard().string = URL.absoluteString
            SVProgressHUD.showSuccessWithStatus("已复制", maskType: .Gradient)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                SVProgressHUD.dismiss()
            }
        })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func pushAnswerViewController(answerButton: UIButton) {
        if let answer = answerButton.msr_userInfo as? Answer {
            msr_navigationController!.pushViewController(AnswerViewController(answer: answer), animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
