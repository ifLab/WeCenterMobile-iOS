//
//  UserEditListViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

protocol UserEditDelegate:NSObjectProtocol {
    func avatarDidPost(controller:UserEditListViewController , image:UIImage)
    func nameDidPost(controller:UserEditListViewController, name:String)
}

class UserEditListViewController:UIViewController,UserPostDelegate,GenderDelegate,UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var delegate:UserEditDelegate?
    var tableView: UITableView?
    var avatarView: UIImageView?
    var dateFormater = NSDateFormatter()
    let model = Model(module: "User", bundle: NSBundle.mainBundle())
    func items1() ->Array<Array<String>> {
//        return [["姓名","性别"],["个人介绍"],["生日"],["居住","教育","行业","工作"]]
        return [[UserStrings["Name"],UserStrings["Gender"]],[UserStrings["Introduction"]],[UserStrings["Birthday"]]]
    }
    
    func items2() ->Array<String>{
        return ["",UserStrings["Introduction"],UserStrings["Other information"]]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = UserStrings["Modify Information"]
        setupViews()
    }
    
    func setupViews()
    {
        
        let body = UIScrollView(frame: self.view.frame)
        body.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        
        dateFormater.dateFormat = "yyyy-MM-dd"
        self.tableView = UITableView(frame:CGRectMake(0, 80, 320, 500) , style: UITableViewStyle.Grouped)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.scrollEnabled = false
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        body.addSubview(self.tableView!)
        body.sizeToFit()
        body.contentSize = CGSizeMake(self.view.frame.width, tableView!.frame.origin.y + tableView!.frame.height)
        
        avatarView = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 40, 18, 80, 80))
        avatarView!.setImageWithURL(NSURL(string: appDelegate.currentUser!.avatarURL))
        avatarView!.layer.cornerRadius = avatarView!.bounds.width / 2
        avatarView!.layer.masksToBounds = true
        var changePhoto = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 40, 18, 80, 80))
        changePhoto.addTarget(self, action: "choosePhoto", forControlEvents: UIControlEvents.TouchUpInside)
        avatarView!.backgroundColor = UIColor.grayColor()
        body.addSubview(avatarView!)
        body.addSubview(changePhoto)
        self.view.addSubview(body)
    }
    func choosePhoto(){
        let title = UserStrings["Select"];
        let cancel = UserStrings["Cancel"];
        let button1 = UserStrings["Pictures"];
        let button2 = UserStrings["Album"];
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
            case 0: return  //取消
            case 1: sourType = UIImagePickerControllerSourceType.Camera; break                 //拍照
            case 2: sourType = UIImagePickerControllerSourceType.PhotoLibrary; break           //相册
            default:return
            }
        }else{
            switch buttonIndex {
            case 0: return  //取消
            case 1: sourType = UIImagePickerControllerSourceType.PhotoLibrary;break          //相册
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
        postPhoto(image)
    }
    
    func postPhoto(image:UIImage){
        var imageData = NSData()
        imageData = UIImageJPEGRepresentation(image, 0.5)
        let manager = model.manager
        manager.POST(model.URLStrings["avatar_upload"],
            parameters: nil,
            constructingBodyWithBlock: {
                data in
                
                data.appendPartWithFileData(imageData, name: "user_avatar", fileName: "image.jpg", mimeType: "image/jpeg")
            },
            success: {
                operation, response in
                #if DEBUG
                println("posted avatar success")
                #endif
                self.avatarView!.image = image
                self.avatarView!.backgroundColor = UIColor.clearColor()
                if (self.delegate != nil ){
                    self.delegate?.avatarDidPost(self, image: image)
                }
                return
            },
            failure: {
                operation, error in
                #if DEBUG
                    println("posted avatar failure")
                #endif
                println(error.userInfo)
                return
            })
        
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
                cell1.textLabel.text = appDelegate.currentUser!.name
            }else{
                var cell2 = UserGenderCell(gender: 1)
                cell2.selectionStyle = UITableViewCellSelectionStyle.None
                cell2.delegate = self
                return cell2
            }
            break
        case 1:
            cell1.textLabel.text = "1" //appDelegate.currentUser!.signature!
            break
        case 2:
            cell1.textLabel.text = dateFormater.stringFromDate( NSDate(timeIntervalSince1970: appDelegate.currentUser!.birthday!))
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
        #if DEBUG
            println("\(indexPath.section)  \(indexPath.row) \(items1()[indexPath.section][indexPath.row])")
        #endif
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.title = nil
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                var postViewController = UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])
                postViewController.delegate = self
            self.presentViewController(UINavigationController(rootViewController: postViewController), animated: true, completion: nil)
            }
            break
        case 1:
            var postViewController = UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])
            postViewController.delegate = self

            self.presentViewController(UINavigationController(rootViewController:postViewController), animated: true, completion: nil)

            break
        case 2:
            var postViewController = UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])
            postViewController.delegate = self

            self.presentViewController(UINavigationController(rootViewController:postViewController), animated: true, completion: nil)
            break
        case 3:
            var postViewController = UserPostViewController(style: items1()[indexPath.section][indexPath.row], title: items2()[indexPath.section])
            postViewController.delegate = self

            self.presentViewController(UINavigationController(rootViewController: postViewController), animated: true, completion: nil)

            break
        default:
            break
        }
        //        let tableview1 = UITableViewController()
        //        self.navigationController.pushViewController(tableview1, animated: true)
        //        self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func GenderSellect(controller: UserGenderCell, theGender: Int) {

        model.POST(model.URLStrings["profile_setting"]!,
            parameters: [

                "uid": appDelegate.currentUser!.id,
                "user_name": appDelegate.currentUser!.name!,
                "sex": theGender

            ],
            success: {
                property in
                #if DEBUG
                    println("posted gender success")
                #endif
                return
            },
            failure: {
                error in
                #if DEBUG
                    println("posted gender failure")
                #endif
                println(error.userInfo)
                return
            })
    }
    
    func postedBirthday(controller: UserPostViewController, date: NSDate) {
        var cell:UITableViewCell! =  self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))
        cell.textLabel.text = dateFormater.stringFromDate(date)!
        print(dateFormater.stringFromDate(date)!)
    }
    
    func postedIntroduction(controller: UserPostViewController, introduction: String) {
        var cell:UITableViewCell! =  self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
        cell.textLabel.text = introduction
    }
    
    func postedName(controller: UserPostViewController, name: String) {
        var cell:UITableViewCell! =  self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        cell.textLabel.text = name
        delegate?.nameDidPost(self, name: name)
    }
}


