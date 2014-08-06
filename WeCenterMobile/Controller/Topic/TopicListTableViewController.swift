//
//  TopicListTableViewController.swift
//  WeCenterMobile
//
//  Created by Jerry Black on 14-7-15.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class TopicListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User?
    var tableView: UITableView?
    var topicList: [Topic]
    
    override init()  {
        topicList = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder!) {
        topicList = aDecoder.decodeObjectForKey("topicList") as [Topic]
        super.init(coder: aDecoder)
    }
    
    class func mineTopicListTableViewController(user : User) -> TopicListTableViewController {
        var instance = TopicListTableViewController()
        instance.user = user
        Topic.fetchMineTopicList(
            instance.user!,
            strategy: .CacheFirst,
            success: {
                topics in
                instance.topicList = topics
                instance.tableView!.reloadData()
            }, failure: {
                error in
            })
        instance.title = "我关注的话题"
        instance.tableView = UITableView(frame:instance.view!.bounds)
        instance.tableView!.delegate = instance
        instance.tableView!.dataSource = instance
        instance.view?.addSubview(instance.tableView!)
        instance.tableView!.rowHeight = CGFloat(70)
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return topicList.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        println("\(indexPath.row)")
        let topic = topicList[indexPath.row]
        return TopicCell(topic: topic, reuseIdentifier: "cell")
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("DidSelectRowAtIndexPath \(indexPath.row)")
        var topic = topicList[indexPath.row]
        msrNavigationController.pushViewController(TopicDetailViewController(user: user!, topic: topic), animated: true) { finished in }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
