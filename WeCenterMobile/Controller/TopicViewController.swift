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
    // WARN: - Should be [Answer]()
    
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
        v.focusButton.addTarget(self, action: "focus", forControlEvents: .TouchUpInside)
        return v
    }()
    
    lazy var bodyView: UITableView = {
        [weak self] in
        let v = UITableView()
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        v.alwaysBounceVertical = true
        v.contentInset.top = self!.header.maxHeight
        v.scrollIndicatorInsets.top = self!.header.minHeight
        v.contentOffset.y = -v.contentInset.top
        v.delegate = self
        v.dataSource = self
        v.separatorStyle = .None
        v.backgroundColor = UIColor.clearColor()
        v.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        v.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        return v
    }()
    
    private var refreshControlImageView: UIImageView! // for keeping weak property in header
    private var refreshControlActivityIndicatorView: UIActivityIndicatorView! // for keeping weak property in header
    
    let cellReuseIdentifier = "TopicViewControllerCell"
    
    override func loadView() {
        super.loadView()
        view.addSubview(bodyView)
        view.addSubview(header)
        view.backgroundColor = UIColor.msr_materialGray900()
        header.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        header.msr_addTopAttachedConstraintToSuperview()
        header.msr_addHeightConstraintWithValue(header.maxHeight)
        let refreshControl = bodyView.addLegendHeaderWithRefreshingTarget(self, refreshingAction: "refresh")
        refreshControl.textColor = UIColor.whiteColor()
        refreshControlImageView = refreshControl.valueForKey("arrowImage") as! UIImageView
        refreshControlImageView.tintColor = UIColor.whiteColor()
        refreshControlImageView.msr_imageRenderingMode = .AlwaysTemplate
        refreshControlActivityIndicatorView = refreshControl.valueForKey("activityView") as! UIActivityIndicatorView
        refreshControlActivityIndicatorView.activityIndicatorViewStyle = .White
        bodyView.msr_addAllEdgeAttachedConstraintsToSuperview()
        bodyView.registerNib(UINib(nibName: "TopicViewControllerCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        automaticallyAdjustsScrollViewInsets = false
        msr_navigationBar!.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        bodyView.header.beginRefreshing()
    }
    
    func reloadData() {
        header.update(topic: topic)
        bodyView.reloadData()
        bodyView.backgroundColor = topic.image?.msr_averageColorWithAccuracy(0.5)?.colorWithAlphaComponent(0.2) ?? UIColor.clearColor()
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
                        self?.bodyView.header.endRefreshing()
                        self?.reloadData()
                        return
                    },
                    failure: {
                        [weak self] error in
                        self?.bodyView.header.endRefreshing()
                        return
                    })
            },
            failure: {
                [weak self] error in
                self?.bodyView.header.endRefreshing()
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TopicViewControllerCell
        cell.update(answer: answers[indexPath.row], updateImage: true)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        struct _Static {
            static var id: dispatch_once_t = 0
            static var cell: TopicViewControllerCell!
        }
        dispatch_once(&_Static.id) {
            _Static.cell = NSBundle.mainBundle().loadNibNamed("TopicViewControllerCell", owner: nil, options: nil).first as! TopicViewControllerCell
        }
        _Static.cell.update(answer: answers[indexPath.row], updateImage: false)
        return _Static.cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === bodyView {
            let offset = bodyView.contentOffset.y + bodyView.contentInset.top
            header.msr_heightConstraint!.constant = floor(min(max(header.maxHeight - offset, header.minHeight), header.maxHeight)) // The appearences of blur effect view will not correct unless it's height is an integer.
            bodyView.scrollIndicatorInsets.top = header.msr_heightConstraint!.constant
            header.layoutIfNeeded()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

