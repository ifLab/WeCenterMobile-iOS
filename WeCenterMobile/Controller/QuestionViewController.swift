//
//  QuestionViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import DTCoreText
import MJRefresh
import SVProgressHUD
import UIKit

class QuestionViewController: UITableViewController, DTLazyImageViewDelegate, QuestionBodyCellLinkButtonDelegate, PublishmentViewControllerDelegate {
    
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
        let c = NSBundle.mainBundle().loadNibNamed("QuestionHeaderCell", owner: nil, options: nil).first as! QuestionHeaderCell
        c.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        return c
    }()
    lazy var questionTitleCell: QuestionTitleCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("QuestionTitleCell", owner: nil, options: nil).first as! QuestionTitleCell
    }()
    lazy var questionTagListCell: QuestionTagListCell = {
        [weak self] in
        let c = NSBundle.mainBundle().loadNibNamed("QuestionTagListCell", owner: nil, options: nil).first as! QuestionTagListCell
        c.tagsButton.addTarget(self, action: "didPressTagsButton:", forControlEvents: .TouchUpInside)
        return c
    }()
    lazy var questionBodyCell: QuestionBodyCell = {
        [weak self] in
        let c = NSBundle.mainBundle().loadNibNamed("QuestionBodyCell", owner: nil, options: nil).first as! QuestionBodyCell
        if let self_ = self {
            c.lazyImageViewDelegate = self_
            c.linkButtonDelegate = self_
            NSNotificationCenter.defaultCenter().addObserver(self_, selector: "attributedTextContentViewDidFinishLayout:", name: DTAttributedTextContentViewDidFinishLayoutNotification, object: c.attributedTextContextView)
        }
        return c
    }()
    lazy var questionFooterCell: QuestionFooterCell = {
        [weak self] in
        let c = NSBundle.mainBundle().loadNibNamed("QuestionFooterCell", owner: nil, options: nil).first as! QuestionFooterCell
        c.focusButton.addTarget(self, action: "toggleFocus", forControlEvents: .TouchUpInside)
        return c
    }()
    lazy var answerAdditionCell: AnswerAdditionCell = {
        [weak self] in
        let c = NSBundle.mainBundle().loadNibNamed("AnswerAdditionCell", owner: nil, options: nil).first as! AnswerAdditionCell
        c.answerAdditionButton.addTarget(self, action: "didPressAdditionButton", forControlEvents: .TouchUpInside)
        return c
    }()
    
    init(question: Question) {
        self.question = question
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: answerCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: answerCellIdentifier)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
        title = "问题详情" // Needs localization
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Share-Button"), style: .Plain, target: self, action: "didPressShareButton")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.header.beginRefreshing()
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
            questionHeaderCell.update(user: question.user, updateImage: true)
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
            answerCell.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
            answerCell.answerButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
            answerCell.update(answer: answers[indexPath.row], updateImage: true)
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
                _Static.answerCell = NSBundle.mainBundle().loadNibNamed(self_.answerCellNibName, owner: nil, options: nil).first as! AnswerCell
            }
        }
        switch indexPath.section {
        case 0:
            questionHeaderCell.update(user: question.user, updateImage: false)
            return questionHeaderCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 1:
            questionTitleCell.update(question: question)
            return questionTitleCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 2:
            questionTagListCell.update(question: question)
            return questionTagListCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 3:
            questionBodyCell.update(question: question)
            let height = questionBodyCell.requiredRowHeightInTableView(tableView)
            let insets = questionBodyCell.attributedTextContextView.edgeInsets
            return height > insets.top + insets.bottom ? height : 0
        case 4:
            questionFooterCell.update(question: question)
            return questionFooterCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 5:
            return answerAdditionCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        default:
            _Static.answerCell.update(answer: answers[indexPath.row], updateImage: false)
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
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    
    func didPressAnswerButton(sender: UIButton) {
        if let answer = sender.msr_userInfo as? Answer {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: answer), animated: true)
        }
    }
    
    func didPressAdditionButton() {
        let apc = NSBundle.mainBundle().loadNibNamed("PublishmentViewControllerB", owner: nil, options: nil).first as! PublishmentViewController
        let answer = Answer.temporaryObject()
        answer.question = Question.temporaryObject()
        answer.question!.id = question.id
        apc.delegate = self
        apc.dataObject = answer
        apc.headerLabel.text = "发布回答"
        showDetailViewController(apc, sender: self)
    }
    
    func publishmentViewControllerDidSuccessfullyPublishDataObject(publishmentViewController: PublishmentViewController) {
        tableView.header.beginRefreshing()
    }
    
    func toggleFocus() {
        var focusing = question.focusing
        question.focusing = nil
        reloadQuestionFooterCell()
        question.toggleFocus(
            success: {
                [weak self] in
                self?.reloadQuestionFooterCell()
                return
            },
            failure: {
                [weak self] error in
                self?.question.focusing = focusing
                self?.reloadQuestionFooterCell()
            })
    }
    
    func refresh() {
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
                                self_.tableView.header.endRefreshing()
                                self_.tableView.reloadData()
                            },
                            failure: {
                                error in
                                self_.tableView.header.endRefreshing()
                                return
                            })
                    } else {
                        self_.tableView.header.endRefreshing()
                    }
                }
                return
            },
            failure: {
                [weak self] error in
                self?.tableView.header.endRefreshing()
                return
            })
    }
    
    func reloadQuestionFooterCell() {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 4)], withRowAnimation: .None)
    }
    
    func didPressShareButton() {
        let title = question.title!
        let image = question.user?.avatar ?? defaultUserAvatar
        let body = question.body!.wc_plainString
        let url = NetworkManager.defaultManager!.website
        var items = [title, body, NSURL(string: url)!]
        if image != nil {
            items.append(image!)
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: [SinaWeiboActivity(), WeChatSessionActivity(), WeChatTimelineActivity()])
        showDetailViewController(vc, sender: self)
    }
    
    func didPressTagsButton(sender: UIButton) {
        if let topics = sender.msr_userInfo as? [Topic] {
            msr_navigationController!.pushViewController(TopicListViewController(topics: topics), animated: true)
        }
    }
    
    func attributedTextContentViewDidFinishLayout(notification: NSNotification) {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
