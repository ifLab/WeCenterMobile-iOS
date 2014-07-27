//
//  UserEditListViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserEditListViewController:UIViewController, UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var tableView : UITableView?
    var photo :UIImageView?
    var user:User?
    func items1() ->Array<Array<String>>{
        return [["姓名","性别"],["一句话介绍"],["个人介绍"],["居住","教育","行业","工作"]]
    }
    
    func items2() ->Array<String>{
        return ["","一句话介绍","个人介绍","其他资料"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "修改个人资料"
        setupViews()
    }
    
    func setupViews()
    {
        let body = UIScrollView(frame: self.view.frame)
        body.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        
        
        self.tableView = UITableView(frame:CGRectMake(0, 80, 320, 600) , style: UITableViewStyle.Grouped)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.scrollEnabled = false
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        body.addSubview(self.tableView)
        body.sizeToFit()
        body.contentSize = CGSizeMake(self.view.frame.width, tableView!.frame.origin.y + tableView!.frame.height)
        
        photo = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 40, 18, 80, 80))
        
        var changePhoto = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 40, 18, 80, 80))
        changePhoto.addTarget(self, action: "choosePhoto", forControlEvents: UIControlEvents.TouchUpInside)
        photo!.backgroundColor = UIColor.grayColor()
        body.addSubview(photo)
        body.addSubview(changePhoto)
        self.view.addSubview(body)
    }
    func choosePhoto(){
        let title = "选择";
        let cancel = "取消";
        let button1 = "拍照";
        let button2 = "相册";
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let sheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: cancel, destructiveButtonTitle: nil, otherButtonTitles:button1, button2)
            sheet.showInView(self.view)
        }else{
            let sheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: cancel, destructiveButtonTitle: nil, otherButtonTitles:  button2)
            sheet.showInView(self.view)
        }

        
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
    
        var sourType:UIImagePickerControllerSourceType
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            switch buttonIndex {
            case 0:println("0"); return  //取消
            case 1:println("1");sourType = UIImagePickerControllerSourceType.Camera; break                 //拍照
            case 2:println("2");sourType = UIImagePickerControllerSourceType.PhotoLibrary; break           //相册
            default:return
            }
        }else{
            switch buttonIndex {
            case 0:println("0"); return  //取消
            case 1:println("1"); sourType = UIImagePickerControllerSourceType.PhotoLibrary;break          //相册
            default:return
            }
        }
        var imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourType
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as UIImage
        photo!.image = image
        photo!.backgroundColor = UIColor.clearColor()
        
    }
    
    
    func actionSheet(actionSheet: UIActionSheet!, didDismissWithButtonIndex buttonIndex: Int) {
        
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return items2()[section]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return items1()[section].count
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        
        return items1().count
    }
    
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell1 = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "UserEditCell")
        switch indexPath.section {
        case 0:
            if indexPath.row == 0{
                cell1.textLabel.text = user?.name
            }else{
                cell1 = UserGenderCell(gender: user!.gender)
                cell1.selectionStyle = UITableViewCellSelectionStyle.None
            }
            break
        case 1:
            cell1.textLabel.text = user?.shortIntroduction
            break
        case 2:
            cell1.textLabel.text = user?.introduction
            break
        case 3:
            
            cell1.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            break
        default:
            break
        }
        //        let cell = tableView .dequeueReusableCellWithIdentifier("editCell", forIndexPath: indexPath) as UITableViewCell
        
                return cell1
    }
    
    
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        println("\(indexPath.section)  \(indexPath.row) \(items1()[indexPath.section][indexPath.row])")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.title = nil
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
            self.presentViewController(UINavigationController(rootViewController: UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])), animated: true, completion: nil)
            }
            break
        case 1:
            self.presentViewController(UINavigationController(rootViewController: UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])), animated: true, completion: nil)

            break
        case 2:
            self.presentViewController(UINavigationController(rootViewController: UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])), animated: true, completion: nil)
            break
        case 3:
            self.presentViewController(UINavigationController(rootViewController: UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])), animated: true, completion: nil)

            break
        default:
            break
        }
        //        let tableview1 = UITableViewController()
        //        self.navigationController.pushViewController(tableview1, animated: true)
        //        self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}