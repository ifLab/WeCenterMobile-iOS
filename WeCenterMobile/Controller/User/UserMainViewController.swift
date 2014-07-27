//
//  UserListViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-20.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit
class UserMainViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource
{
    var tableView : UITableView?
    var items : NSMutableArray?
    var mainview : UserMainView?
    var user:User?
    func items1() ->Array<Array<String>>{
        return [["发问","回复","文章","关注","动态"]]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        self.title = "我的资料"
        self.items = NSMutableArray()
        // self.items?.addObject("1","2")
        // Do any additional setup after loading the view, typically from a nib.
        
        setupViews()
        setupRightBarButtonItem()
        setupLeftBarButtonItem()
        
    }
    
    func setupViews()
    {
        user = User()
//        user?.fetchInformation(nil, failure: nil)
        mainview = UserMainView(frame: CGRectMake(0, 0, 320, 150), user: user!)
        let body = UIScrollView(frame: self.view.frame)
        mainview!.sizeToFit()
        mainview!.frame = CGRectMake(0, 0, mainview!.frame.width, mainview!.like.frame.origin.y + mainview!.like.frame.height + 10)
        
        body.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        body.addSubview(mainview)
        self.tableView = UITableView(frame:CGRectMake(0, mainview!.frame.height , 320, 310) , style: UITableViewStyle.Grouped)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.scrollEnabled = false
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        body.addSubview(self.tableView)
        body.sizeToFit()
        body.contentSize = CGSizeMake(self.view.frame.width, mainview!.frame.height + tableView!.frame.height)
        self.view.addSubview(body)
        self.mainview?.topic.addTarget(self, action: "pushTableView", forControlEvents: UIControlEvents.TouchUpInside)
        self.mainview?.careMe.addTarget(self, action: "pushTableView", forControlEvents: UIControlEvents.TouchUpInside)
        self.mainview?.iCare.addTarget(self, action: "pushTableView", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func setupLeftBarButtonItem()
    {
        var leftBarButton = UIBarButtonItem(image: UIImage(named: "Category"), style: UIBarButtonItemStyle.Plain, target: self, action:"leftBarButtonItemClicked" )
//        var leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "leftBarButtonItemClicked" )
        self.navigationItem!.leftBarButtonItem = leftBarButton
    }
    
    func setupRightBarButtonItem()
    {
        var rightBarButton = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self, action: "rightBarButtonItemClicked" )
        self.navigationItem!.rightBarButtonItem = rightBarButton
    }
    
    func pushTableView(){
        let tableview1 = UITableViewController()
        self.navigationController.pushViewController(tableview1, animated: true)
    }
    
    func rightBarButtonItemClicked()
    {
        var userEditView = UserEditListViewController()
        userEditView.user = user
        self.navigationController.pushViewController(userEditView, animated: true)
    }
    
    func leftBarButtonItemClicked()
    {
        var sidebar = self.navigationController.view.subviews[2] as Msr.UI.Sidebar
        sidebar.show(completion: nil, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return items1()[section].count
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int{
        
        return items1().count
    }
    
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text =  items1()[indexPath.section][indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        let tableview1 = UITableViewController()
        self.navigationController.pushViewController(tableview1, animated: true)
        self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}
    