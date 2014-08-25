//
//  TopicViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/17.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    enum ImageButtonState {
        case Normal
        case NotFollowing
        case Following
    }
    
    var topView = UIScrollView()
    var hideableView = UIView()
    var imageButton = BFPaperButton(raised: false)
    var imageButtonState = ImageButtonState.Normal
    var imageButtonTimer: NSTimer? = nil
    var imageActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var titleLabel = UILabel()
    var countLabel = UILabel()
    var introductionLabel = UILabel()
    var tableView = UITableView(frame: CGRectZero, style: .Plain)
    var tableViewCellReuseIdentifier = "WE_CENTER_MOBILE@TOPIC_VIEW_CONTROLLER+TABLE_VIEW-QUESTION_ANSWER_CELL-REUSE_IDENTIFIER"
    var outstandingAnswerButton = RectangleCoverButton()
    
    var topicID: NSNumber!
    var topic: Topic!
    var array: [(question: Question, answer: Answer, user: User)] = []
    
    init(topicID: NSNumber) {
        super.init()
        self.topicID = topicID
        view = UIScrollView(frame: UIScreen.mainScreen().bounds)
        (view as UIScrollView).bounces = false
        
        view.addSubview(tableView)
        view.addSubview(topView)
        topView.addSubview(imageButton)
        topView.addSubview(titleLabel)
        topView.addSubview(countLabel)
        imageButton.addSubview(imageActivityIndicatorView)
        tableView.addSubview(hideableView)
        
        hideableView.addSubview(introductionLabel)
        topView.frame = CGRect(x: 0, y: -(UINavigationController().navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height), width: view.bounds.width, height: 140)
        topView.backgroundColor = UIColor.paperColorGray300()
        topView.delaysContentTouches = false
        topView.layer.masksToBounds = false
        tableView.frame = CGRect(x: 0, y: topView.frame.origin.y + topView.bounds.height, width: view.bounds.width, height: view.frame.height - topView.bounds.height)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.alwaysBounceVertical = true
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(QuestionAnswerCell.self, forCellReuseIdentifier: tableViewCellReuseIdentifier)
        hideableView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.1)
        hideableView.backgroundColor = topView.backgroundColor
        imageButton.bounds.size = CGSize(width: 80, height: 80)
        imageButton.center.x = topView.center.x - 90
        imageButton.frame.origin.y = 40
        imageButton.layer.cornerRadius = imageButton.bounds.width / 2
        imageButton.layer.masksToBounds = true
        imageButton.addTarget(self, action: "toggleImageButtonImage", forControlEvents: .TouchUpInside)
        imageButton.addTarget(self, action: "delayHidingImageButtonImage", forControlEvents: .TouchDown)
        imageButton.imageView.frame = imageButton.bounds
        imageButton.usesSmartColor = false
        imageButton.tapCircleColor = UIColor(white: 1, alpha: 0.5)
        imageActivityIndicatorView.frame = imageButton.bounds
        imageActivityIndicatorView.userInteractionEnabled = false
        titleLabel.frame = CGRect(x: imageButton.frame.origin.x + imageButton.frame.width + 20, y: 0, width: 160, height: 26)
        titleLabel.center.y = imageButton.center.y - 15
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        titleLabel.textColor = UIColor.blackColor()
        countLabel.frame = CGRect(x: titleLabel.frame.origin.x + 2, y: 0, width: titleLabel.bounds.width, height: 24)
        countLabel.center.y = imageButton.center.y + 15
        countLabel.font = UIFont.systemFontOfSize(16)
        countLabel.textColor = UIColor.paperColorGray700()
        countLabel.numberOfLines = 0
        introductionLabel.frame.size = CGSize(width: hideableView.bounds.width - 30, height: 0)
        introductionLabel.numberOfLines = 0
        introductionLabel.font = UIFont.systemFontOfSize(14)
        introductionLabel.textColor = UIColor.paperColorGray800()
        scrollViewDidScroll(tableView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(animated: Bool) {
        let msr_navigationBar = Msr.UI.navigationBarOfViewController(self)
        msr_navigationBar!.hidden = true
        Topic.fetchTopicByID(topicID,
            strategy: .NetworkFirst,
            success: {
                topic in
                self.topic = topic
                self.reloadData()
                Topic.fetchTopicOutstandingQuestionAnswerListUsingNetworkByTopicID(self.topicID,
                    success: {
                        array in
                        self.array = array
                        self.tableView.reloadData()
                    },
                    failure: nil)
            },
            failure: nil)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView!, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(tableView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if scrollView === tableView {
            if tableView.contentOffset.y < -self.hideableView.bounds.height {
                topView.frame.size.height = 140 - tableView.contentOffset.y - hideableView.bounds.height
                topView.contentOffset.y = tableView.contentOffset.y + hideableView.bounds.height
            } else {
                topView.frame.size.height = 140
                let percentage = min(tableView.contentOffset.y + hideableView.bounds.height, hideableView.bounds.height) / hideableView.bounds.height
                topView.contentOffset.y = percentage * 5
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView!) {
        if scrollView === tableView {
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .BeginFromCurrentState,
                animations: {
                    if self.tableView.contentOffset.y < -self.hideableView.bounds.height / 2 {
                        self.tableView.contentOffset.y = -self.hideableView.bounds.height
                    } else if self.tableView.contentOffset.y < 0 {
                        self.tableView.contentOffset.y = 0
                    }
                },
                completion: nil)
        }
    }
    
    func reloadData() {
        titleLabel.text = topic.title
        if topic.imageURL != nil {
            imageButton.setBackgroundImageForState(.Normal, withURL: NSURL(string: topic.imageURL!), placeholderImage: UIImage.circleWithColor(UIColor.paperColorGray400(), radius: imageButton.bounds.width / 2))
        }
        countLabel.text = "\(topic.focusCount!)人关注"
        introductionLabel.text = topic.introduction
        introductionLabel.frame = CGRect(origin: CGPoint(x: 15, y: 0), size: introductionLabel.sizeThatFits(CGSize(width: introductionLabel.bounds.width, height: CGFloat.max)))
        hideableView.frame.size.height = introductionLabel.bounds.height + 10
        hideableView.frame.origin.y = -hideableView.frame.size.height
        tableView.contentInset.top = hideableView.bounds.height
        tableView.contentOffset.y = -tableView.contentInset.top
    }
    
    func delayHidingImageButtonImage() {
        preventHidingImageButtonImage()
        tryHidingImageButtonImage()
    }
    
    func preventHidingImageButtonImage() {
        imageButtonTimer?.invalidate()
        imageButtonTimer = nil
    }
    
    func tryHidingImageButtonImage() {
        imageButtonTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "doHidingImageButtonImage", userInfo: nil, repeats: false)
    }
    
    func doHidingImageButtonImage() {
        self.imageButtonState = .Normal
        imageButton.userInteractionEnabled = false
        UIView.animateWithDuration(0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .BeginFromCurrentState,
            animations: {
                self.imageButton.imageView.alpha = 0
            }, completion: {
                finished in
                self.imageButton.setImage(nil, forState: .Normal)
                self.imageButton.userInteractionEnabled = true
            })
    }
    
    func toggleImageButtonImage() {
        if topic?.focused != nil {
            switch imageButtonState {
            case .Normal:
                if topic!.focused! {
                    imageButton.setImage(UIImage(named: "User_Following"), forState: .Normal)
                    imageButtonState = .Following
                } else {
                    imageButton.setImage(UIImage(named: "User_Follow"), forState: .Normal)
                    imageButtonState = .NotFollowing
                }
                imageButton.userInteractionEnabled = false
                UIView.animateWithDuration(0.2,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: {
                        self.imageButton.imageView.alpha = 1
                    }, completion: {
                        finished in
                        self.imageButton.userInteractionEnabled = true
                    })
                break
            case .NotFollowing, .Following:
                imageActivityIndicatorView.startAnimating()
                imageButton.userInteractionEnabled = false
                preventHidingImageButtonImage()
                topic!.toggleFocusTopicUsingNetworkByUserID(appDelegate.currentUser!.id,
                    success: {
                        self.tryHidingImageButtonImage()
                        self.imageActivityIndicatorView.stopAnimating()
                        self.imageButton.userInteractionEnabled = true
                        if self.topic!.focused! {
                            self.imageButton.setImage(UIImage(named: "User_Following"), forState: .Normal)
                            self.imageButtonState = .Following
                        } else {
                            self.imageButton.setImage(UIImage(named: "User_Follow"), forState: .Normal)
                            self.imageButtonState = .NotFollowing
                        }
                    },
                    failure: {
                        error in
                        self.tryHidingImageButtonImage()
                        self.imageActivityIndicatorView.stopAnimating()
                        self.imageButton.userInteractionEnabled = true
                    })
                break
            default:
                break
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let data = array[indexPath!.row]
        var cell = tableView!.dequeueReusableCellWithIdentifier(tableViewCellReuseIdentifier, forIndexPath: indexPath) as? QuestionAnswerCell
        if cell == nil {
            cell = QuestionAnswerCell(style: .Default, reuseIdentifier: tableViewCellReuseIdentifier)
        }
        cell!.update(data: data, width: tableView!.bounds.width)
        cell!.userButton.addTarget(self, action: "pushUserViewController:", forControlEvents: .TouchUpInside)
        cell!.questionButton.addTarget(self, action: "pushQuestionViewController:", forControlEvents: .TouchUpInside)
        if data.user.avatar != nil {
            cell!.userButton.setImage(data.user.avatar, forState: .Normal)
        } else {
            data.user.fetchAvatarImage(
                success: {
                    if cell!.userButton.tag == data.user.id {
                        cell!.userButton.setImage(data.user.avatar, forState: .Normal)
                    }
                },
                failure: nil)
        }
        return cell
    }
    
    func pushUserViewController(userButton: UIButton) {
/// @TODO: This version of implementation will cause compiler crash on Xcode 6 Beta 6. Temporarily removed for future use.
//        msr_navigationController!.pushViewController(UserViewController(userID: userButton.msr_userInfo as NSNumber), animated: true, completion: nil)
    }
    
    func pushQuestionViewController(questionButton: UIButton) {
        let msr_navigationController = Msr.UI.navigationControllerOfViewController(self)
/// @TODO
        msr_navigationController!.pushViewController(QuestionViewController(questionID: questionButton.tag), animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let cell = QuestionAnswerCell(style: .Default, reuseIdentifier: tableViewCellReuseIdentifier)
        cell.update(data: array[indexPath.row], width: tableView.bounds.width)
        return cell.bounds.height
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}

