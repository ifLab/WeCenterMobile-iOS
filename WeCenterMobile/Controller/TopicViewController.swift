//
//  TopicViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var topic: Topic
    var answers = [Answer]()
    
    init(topic: Topic) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var header: TopicHeaderView = {
        [weak self] in
        let v = TopicHeaderView()
        v.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        v.focusButton.addTarget(self, action: "focus", forControlEvents: .TouchUpInside)
        v.backButton.addTarget(self, action: "didPressBackButton", forControlEvents: .TouchUpInside)
        return v
    }()
    
    lazy var bodyView: UITableView = {
        [weak self] in
        let theme = SettingsManager.defaultManager.currentTheme
        let v = UITableView()
        v.frame = self!.view.bounds
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        v.alwaysBounceVertical = true
        v.indicatorStyle = theme.scrollViewIndicatorStyle
        v.contentInset.top = UIApplication.sharedApplication().statusBarFrame.height
        v.scrollIndicatorInsets.top = self!.header.minHeight
        v.contentOffset.y = -v.contentInset.top
        v.separatorStyle = .None
        v.backgroundColor = UIColor.clearColor()
        v.estimatedRowHeight = 120
        v.rowHeight = UITableViewAutomaticDimension
        v.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        v.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        v.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        v.dataSource = self
        v.delegate = self
        v.addSubview(self!.header)
        self!.header.frame = CGRect(x: 0, y: -UIApplication.sharedApplication().statusBarFrame.height, width: v.bounds.width, height: self!.header.maxHeight)
        return v
    }()
    
    let cellReuseIdentifier = "TopicViewControllerCell"
    let cellNibName = "AnswerCellWithQuestionTitle"
    
    override func loadView() {
        super.loadView()
        let theme = SettingsManager.defaultManager.currentTheme
        view.addSubview(bodyView)
        view.backgroundColor = theme.backgroundColorA
        bodyView.msr_uiRefreshControl = UIRefreshControl()
        bodyView.msr_uiRefreshControl!.tintColor = theme.footnoteTextColor
        bodyView.msr_uiRefreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        bodyView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        automaticallyAdjustsScrollViewInsets = false
        msr_navigationBar!.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        bodyView.msr_uiRefreshControl!.beginRefreshing()
        refresh()
    }
    
    func reloadData() {
        header.update(topic: topic)
        bodyView.reloadData()
    }
    
    func refresh() {
        Topic.fetch(
            ID: topic.id,
            success: {
                [weak self] topic in
                self?.topic = topic
                self?.reloadData()
                topic.fetchOutstandingAnswers(
                    success: {
                        [weak self] answers in
                        self?.answers = answers
                        self?.bodyView.msr_uiRefreshControl!.endRefreshing()
                        self?.reloadData()
                        return
                    },
                    failure: {
                        [weak self] error in
                        self?.bodyView.msr_uiRefreshControl!.endRefreshing()
                        return
                    })
            },
            failure: {
                [weak self] error in
                self?.bodyView.msr_uiRefreshControl!.endRefreshing()
                return
            })
    }
    
    func focus() {
        let focused = topic.focused
        topic.focused = nil
        reloadData()
        topic.focused = focused
        topic.toggleFocus(
            userID: User.currentUser!.id,
            success: {
                [weak self] in
                self?.reloadData()
                return
            },
            failure: {
                [weak self] error in
                self?.reloadData()
                return
            })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return header.maxHeight - UIApplication.sharedApplication().statusBarFrame.height + 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.userInteractionEnabled = false
        v.hidden = true
        return v
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! AnswerCellWithQuestionTitle
        cell.update(answer: answers[indexPath.row])
        cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
        cell.answerButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
        cell.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === bodyView {
            let offset = bodyView.contentOffset.y
            header.frame.size.height = floor(max(header.maxHeight - offset - UIApplication.sharedApplication().statusBarFrame.height, header.minHeight)) // The appearences of blur effect view will not correct unless it's height is an integer.
            header.frame.origin.y = offset
            bodyView.scrollIndicatorInsets.top = header.bounds.height
        }
    }
    
    func didPressQuestionButton(sender: UIButton) {
        if let question = sender.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    
    func didPressAnswerButton(sender: UIButton) {
        if let answer = sender.msr_userInfo as? Answer {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: answer), animated: true)
        }
    }
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    
    func didPressBackButton() {
        msr_navigationController!.popViewController(animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
}

