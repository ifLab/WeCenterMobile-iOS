//
//  UserPostViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

protocol UserPostDelegate: NSObjectProtocol{
    func postedBirthday(controller:UserPostViewController, date:NSDate)
    func postedName(controller:UserPostViewController, name:String)
    func postedIntroduction(controller:UserPostViewController, introduction:String)

    
}

class UserPostViewController: UIViewController {
    
    let user:User?
    let headerTitle: String?
    var textField: UITextField?
    var textView: UITextView?
    var bodyView: UIScrollView?
    let tip: UILabel?
    let publishButton: UIBarButtonItem?
    let cancelButton: UIBarButtonItem?
    var datePicker: UIDatePicker?
    
    var delegate:UserPostDelegate?
    
    init(style:String , title:String){
        super.init(nibName: nil, bundle: nil)
        headerTitle = title
        publishButton = UIBarButtonItem(title: UserStrings["Publish"], style: UIBarButtonItemStyle.Done, target: self , action: "postData" )
        cancelButton = UIBarButtonItem(title: UserStrings["Cancel"], style: UIBarButtonItemStyle.Done, target: self, action: "turnBack")
        self.navigationItem.rightBarButtonItem = publishButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.view.backgroundColor =  UIColor.whiteColor()
          bodyView = UIScrollView(frame: self.view.frame)
        
        
//        "Name" = "姓名";
//        "Gender" = "性别";
//        "Introduction" = "个人介绍";
//        "Birthday" = "生日";
//        "Other information" = "其他资料";
        
        if headerTitle == "" {
            headerTitle = UserStrings["Name"]
            setTextField()
            textField!.text = user?.name
            bodyView!.addSubview(textField!)
            bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        }
        if headerTitle == UserStrings["Introduction"]{
//            textView!.text = user?.introduction
            setTextView()
            bodyView!.addSubview(textView!)
            
        }
        if headerTitle == UserStrings["Other information"]{
            headerTitle = style
            if headerTitle == UserStrings["Birthday"] {
                setDatePicker()
                bodyView!.addSubview(datePicker!)
                bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
            }

            bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        }
        self.title = UserStrings["Modify"] + " " + headerTitle!
        self.view.addSubview(bodyView!)
    }
    func postData() {
        if headerTitle == UserStrings["Birthday"] {
            let date:NSDate = datePicker!.date
            let time:Int = Int(date.timeIntervalSince1970)
            UserModel.POST("profile_setting",
                parameters: [

                    "uid": appDelegate.currentUser!.id,
                    "user_name": appDelegate.currentUser!.name!,
                    "birthday": time

                ],
                success: {
                    data in
                    if ((self.delegate) != nil) {
                        self.delegate?.postedBirthday(self, date: date)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return
                },
                failure: nil)

        }
        if headerTitle == UserStrings["Introduction"]{
            UserModel.POST("profile_setting",
                parameters: [

                    "uid": appDelegate.currentUser!.id,
                    "user_name": appDelegate.currentUser!.name!,
                    "signature": textView!.text

                ],
                success: {
                    data in
                    if ((self.delegate) != nil) {
                        self.delegate?.postedIntroduction(self, introduction: self.textView!.text)
                    }
                     self.dismissViewControllerAnimated(true, completion: nil)
                },
                failure: nil)
        }else if headerTitle == UserStrings["Other information"]{
        
            
        }else {
            if textField?.text == nil {
                return
            }
            UserModel.POST("profile_setting",
                parameters: [
                    "uid": appDelegate.currentUser!.id,
                   "user_name": textField!.text
                    

                ],
                success: {
                    data in
                    self.delegate?.postedName(self, name:self.textField!.text)
                    self.dismissViewControllerAnimated(true, completion: nil)
                },
                failure: nil)
        }
       
    }
    
    func turnBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setTextView() {
        textView = UITextView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 57))
        textView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight

    }
    func setTextField() {
        textField = UITextField(frame: CGRectMake(bodyView!.frame.width * 0.02, 5, bodyView!.frame.width * 0.96 , 40))
        textField!.borderStyle = UITextBorderStyle.RoundedRect
        textField!.returnKeyType = UIReturnKeyType.Done
        textField!.keyboardAppearance = UIKeyboardAppearance.Default
        textField!.keyboardType = UIKeyboardType.Default
        textField!.clearButtonMode = .WhileEditing
    }
    func setDatePicker() {
        datePicker = UIDatePicker(frame: CGRectMake(2, self.view.frame.height * 0.2, self.view.frame.width - 4, 100))
        datePicker!.datePickerMode = UIDatePickerMode.Date
    }
}

