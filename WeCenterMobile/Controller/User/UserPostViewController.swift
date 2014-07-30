//
//  UserPostViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserPostViewController :UIViewController {
    
    let user:User?
    let headerTitle:String
    var textField:UITextField?
    var textView:UITextView?
    var bodyView:UIScrollView?
    let tip:UILabel?
    let postButton:UIBarButtonItem?
    let cancelButton:UIBarButtonItem?
    var datePicker:UIDatePicker?
    let model = Model(module: "User", bundle: NSBundle.mainBundle())
    init(style:String , title:String){
        headerTitle = title
        super.init(nibName: nil, bundle: NSBundle.mainBundle())
        postButton = UIBarButtonItem(title: "发布", style: UIBarButtonItemStyle.Done, target: self , action: "postData" )
        cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Done, target: self, action: "turnBack")
        self.navigationItem.rightBarButtonItem = postButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.view.backgroundColor =  UIColor.whiteColor()
          bodyView = UIScrollView(frame: self.view.frame)
        if headerTitle == "" {
            headerTitle = "姓名"
            setTextField()
            textField!.text = user?.name
            bodyView!.addSubview(textField)
            bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        }
        if headerTitle == "个人介绍"{
//            textView!.text = user?.introduction
            setTextView()
            bodyView!.addSubview(textView)
            
        }
        if headerTitle == "其他资料"{
            headerTitle = style
            if headerTitle == "生日" {
                setDatePicker()
                println("1")
                bodyView!.addSubview(datePicker)
                bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
            }

            bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        }
        self.title = "修改" + headerTitle
        self.view.addSubview(bodyView)
    }
    func postData() {
        if headerTitle == "生日" {
            let date:NSDate = datePicker!.date
            let time:Int = Int(date.timeIntervalSince1970)
            model.POST(model.URLStrings["profile_setting"]!,
                parameters: [
                    //                    "uid": user!.uid
                    "uid": "9",
                    "user_name": "eric",
                    "birthday": time
                    //                    "user_name": name,
                    //                    "password": password
                ],
                success: {
                    operation, property in
                    println("success")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return
                },
                failure: {
                    operation, error in
                    println(error.userInfo)
                    return
                })

        }
        if headerTitle == "个人介绍"{
            model.POST(model.URLStrings["profile_setting"]!,
                parameters: [
                    //                    "uid": user!.uid
                    "uid": "9",
                    "user_name": "eric",
                    "signature": textView!.text
                    //                    "user_name": name,
                    //                    "password": password
                ],
                success: {
                    operation, property in
                    println("success")
                     self.dismissViewControllerAnimated(true, completion: nil)
                    return
                },
                failure: {
                    operation, error in
                    println(error.userInfo)
                    return
                })
        }else if headerTitle == "其他资料"{
        
            
        }else {
            if textField?.text == nil {
                return
            }
            model.POST(model.URLStrings["profile_setting"]!,
                parameters: [
//                    "uid": user!.uid
                    "uid": "9",
                    "user_name": textField!.text
                    
//                    "user_name": name,
//                    "password": password
                ],
                success: {
                    operation, property in
                    println("success")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return
                },
                failure: {
                    operation, error in
                    println(error.userInfo)
                    return
                })
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

