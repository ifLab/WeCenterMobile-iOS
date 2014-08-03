//
//  UserListViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-20.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView?
    var items: NSMutableArray?
    var mainview: UserMainView?
    var user: User?
    let model = Model(module: "User", bundle: NSBundle.mainBundle())

    func items1() -> [[String]] {
        return [["发问","回复","文章"],["动态"],["查找好友"]]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        title = "我的资料"
        items = NSMutableArray()
        // self.items?.addObject("1","2")
        // Do any additional setup after loading the view, typically from a nib.
        
        setupViews()
        setupRightBarButtonItem()
        setupLeftBarButtonItem()
    }
    
    func setupViews()
    {
        mainview = UserMainView(frame: CGRectMake(0, 0, 320, 150), user: user!)
        view = UIScrollView(frame: self.view.frame)
        (view as UIScrollView).alwaysBounceVertical = true
        mainview!.sizeToFit()
        mainview!.frame = CGRectMake(0, 0, mainview!.frame.width, mainview!.like.frame.origin.y + mainview!.like.frame.height + 10)
        
        view.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        view.addSubview(mainview)
        self.tableView = UITableView(frame:CGRectMake(0, mainview!.frame.height , 320, 500) , style: UITableViewStyle.Grouped)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.scrollEnabled = false
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(self.tableView)
        view.sizeToFit()
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
        msrNavigationController.pushViewController(tableview1, animated: true) { finished in }
    }
    
    func rightBarButtonItemClicked()
    {
        var userEditView = UserEditListViewController()
        userEditView.user = user
        msrNavigationController.pushViewController(userEditView, animated: true) { finished in }
    }
    
    func leftBarButtonItemClicked()
    {
        var sidebar = appDelegate.mainViewController.sidebar
        sidebar.toggleShow(animated: true, completion: nil)
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
        msrNavigationController.pushViewController(tableview1, animated: true) { finished in }
        self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}
