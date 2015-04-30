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
    var answers = DataManager.defaultManager!.fetchAll("Answer", error: nil) as! [Answer]
    // WARN: - Should be [Answer]() //
    
    init(topic: Topic) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var header: TopicViewControllerHeaderView = {
        [weak self] in
        let v = NSBundle.mainBundle().loadNibNamed("TopicViewControllerHeaderView", owner: nil, options: nil).first as! TopicViewControllerHeaderView
        v.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        v.focusButton.addTarget(self, action: "focus", forControlEvents: .TouchUpInside)
        v.backButton.addTarget(self, action: "didPressBackButton", forControlEvents: .TouchUpInside)
        return v
    }()
    
    lazy var bodyView: UITableView = {
        [weak self] in
        let v = ButtonTouchesCancelableTableView()
        v.frame = self!.view.bounds
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        v.alwaysBounceVertical = true
        v.contentInset.top = UIApplication.sharedApplication().statusBarFrame.height
        v.scrollIndicatorInsets.top = self!.header.minHeight
        v.contentOffset.y = -v.contentInset.top
        v.delegate = self
        v.dataSource = self
        v.separatorStyle = .None
        v.backgroundColor = UIColor.clearColor()
        v.indicatorStyle = .White
        v.estimatedRowHeight = 120
        v.rowHeight = UITableViewAutomaticDimension
        v.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        v.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        v.addSubview(self!.header)
        self!.header.frame = CGRect(x: 0, y: -UIApplication.sharedApplication().statusBarFrame.height, width: v.bounds.width, height: self!.header.maxHeight)
        return v
    }()
    
    let cellReuseIdentifier = "TopicViewControllerCell"
    let cellNibName = "AnswerCellWithQuestionTitle"
    
    override func loadView() {
        super.loadView()
        view.addSubview(bodyView)
        view.backgroundColor = UIColor.msr_materialGray900()
        bodyView.msr_uiRefreshControl = UIRefreshControl()
        bodyView.msr_uiRefreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        bodyView.msr_uiRefreshControl!.tintColor = UIColor.whiteColor()
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
        bodyView.backgroundColor = TintColorFromColor(topic.image?.msr_averageColorWithAccuracy(0.5)).colorWithAlphaComponent(0.3)
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
        cell.update(answer: answers[indexPath.row], updateImage: true)
        cell.questionButton.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
        cell.answerButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
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
    
    func didPressQuestionButton(button: UIButton) {
        if let question = button.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    
    func didPressAnswerButton(button: UIButton) {
        if let answer = button.msr_userInfo as? Answer {
            msr_navigationController!.pushViewController(AnswerViewController(answer: answer), animated: true)
        }
    }
    
    func didPressBackButton() {
        msr_navigationController!.popViewController(animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

