//
//  UserListViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-20.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserMainViewController: UITableViewController {
    let titles = [
        ["回复","发问","文章"],
        ["动态"],
        ["查找好友"]
    ]
    
    convenience init() {
        self.init(style: .Grouped)
        title = "我的资料"
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        var leftBarButton = UIBarButtonItem(image: UIImage(named: "Category"), style: UIBarButtonItemStyle.Plain, target: self, action:"leftBarButtonItemClicked" )
        self.navigationItem!.leftBarButtonItem = leftBarButton
        var rightBarButton = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self, action: "rightBarButtonItemClicked" )
        self.navigationItem!.rightBarButtonItem = rightBarButton
    }
    
    func pushTableView() {
        let tableview1 = UITableViewController()
        msrNavigationController.pushViewController(tableview1, animated: true) { finished in }
    }
    
    func rightBarButtonItemClicked() {
        var userEditView = UserEditListViewController()
        msrNavigationController.pushViewController(userEditView, animated: true) { finished in }
    }
    
    func leftBarButtonItemClicked() {
        var sidebar = appDelegate.mainViewController.sidebar
        sidebar.toggleShow(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return titles[section - 1].count
        }
    }
    
    override func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return indexPath.section != 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return titles.count + 1
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let cell = UserMainCell(user: appDelegate.currentUser!, reuseIndentifer: "elseU")
        if indexPath.section == 0 {
            return cell.cellHeight!
        }else{
            return  40
        }
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let identifier = "\(indexPath)"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil {
            if indexPath.section == 0 {
                return UserMainCell(user: appDelegate.currentUser!, reuseIndentifer: identifier) // Needs specification
            } else {
                cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
                cell.textLabel.text = titles[indexPath.section - 1][indexPath.row]
                cell.accessoryType = .DisclosureIndicator
                if indexPath.section == 1 && indexPath.row <= 1 {
                    let number = indexPath.row == 0 ? appDelegate.currentUser!.answerCount : appDelegate.currentUser!.questionCount
                    var countLabel = UILabel(frame: CGRect(x: cell.frame.width - 100, y: 10, width: 67, height: 18))
                    countLabel.text = "\(number!)"
                    countLabel.font = UIFont.systemFontOfSize(13)
                    countLabel.textColor = UIColor.grayColor()
                    countLabel.textAlignment = NSTextAlignment.Right
                    
                    cell.addSubview(countLabel)
                }
               
                
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let tableview1 = UITableViewController()
        msrNavigationController.pushViewController(tableview1, animated: true) { finished in }
        self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
