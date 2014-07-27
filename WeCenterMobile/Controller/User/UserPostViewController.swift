//
//  UserPostViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserPostViewController :UIViewController {
    
    let headerTitle:String
    var textField:UITextField?
    var textView:UITextView?
    var bodyView:UIScrollView?
    let tip:UILabel?
    let postButton:UIBarButtonItem?
    let cancelButton:UIBarButtonItem?
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
            bodyView!.addSubview(textField)
            bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        }
        if headerTitle == "一句话介绍" {
            setTextField()
            bodyView!.addSubview(textField)
            bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        }
        
        if headerTitle == "个人介绍"{
            setTextView()
            bodyView!.addSubview(textView)
            
        }
        if headerTitle == "其他资料"{
            headerTitle = style
            bodyView!.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 244/255, alpha: 1)
        }
        self.title = "修改" + headerTitle
      

      

       
        self.view.addSubview(bodyView)
    }
    func postData() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
}

