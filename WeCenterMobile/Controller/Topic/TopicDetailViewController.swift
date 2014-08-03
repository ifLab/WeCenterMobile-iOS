//
//  TopicDetailViewController.swift
//  WeCenterMobile
//
//  Created by Jerry Black on 14-7-24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicDetailViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource
{
    var topic : Topic?
    var tableView : UITableView?
    var items : NSMutableArray?
    var firstCell : TopicDetailCell
    var secondCell : TopicDetailCell
    
    init(userID: Int, topicID : Int) {
        topic =
        firstCell = TopicDetailCell.getFirstCell(topic!, reuseIdentifier: "first")
        secondCell = TopicDetailCell.getSecondCell(topic!, reuseIdentifier: "second")
        super.init(nibName: nil, bundle: nil)
        Topic.fetchTopicDetail(
            userID,
            topicID: topicID,
            success: {
                topic in
                self.topic = topic
                self.firstCell = TopicDetailCell.getFirstCell(topic, reuseIdentifier: "first")
                self.secondCell = TopicDetailCell.getSecondCell(topic, reuseIdentifier: "second")
                if topic.beFocus.boolValue {
                    self.follow()
                } else {
                    self.unfollow()
                }
                self.tableView!.reloadData()
            },
            failure: {
                error in
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "话题"
        items = NSMutableArray()
        tableView = UITableView(frame: self.view!.bounds, style: .Grouped)
        tableView!.delegate = self
        tableView!.dataSource = self
        view!.addSubview(self.tableView)
        tableView!.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        tableView!.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
//        setupLeftBarButtonItem()
    }
    
    func setupLeftBarButtonItem() {
        var leftBarButton = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: self, action: "leftBarButtonItemClicked" )
        self.navigationItem!.leftBarButtonItem = leftBarButton
    }
    
    func leftBarButtonItemClicked() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        //若要显示话题详情的更多内容请改为3
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        if section == 1 {
            return 3
        }
        if section == 2 {
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return firstCell.introductLabel.frame.size.height + 80
            }
            if indexPath.row == 1 {
                return 50
            }
        }
        return 43
    }
    
    func pushTableView() {
        let tableview = UITableViewController()
        self.navigationController.pushViewController(tableview, animated: true)
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return firstCell
            }
            if indexPath.row == 1 {
                return secondCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView!, willSelectRowAtIndexPath indexPath: NSIndexPath!) -> NSIndexPath! {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    
    func follow() {
        secondCell.followButton.setBackgroundImage(Msr.UI.RoundedRectangle(color: UIColor.greenColor(), size: secondCell.followButton.frame.size, cornerRadius: (5, 5, 5, 5)).image, forState: .Normal)
        secondCell.followButton.setTitle("取消关注", forState: .Normal)
        secondCell.followButton.addTarget(self, action: "unfollow", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func unfollow() {
        secondCell.followButton.setBackgroundImage(Msr.UI.RoundedRectangle(color: UIColor.redColor(), size: secondCell.followButton.frame.size, cornerRadius: (5, 5, 5, 5)).image, forState: .Normal)
        secondCell.followButton.setTitle("关注", forState: .Normal)
        secondCell.followButton.addTarget(self, action: "follow", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
}