//
//  UserGenderCell.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-25.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserGenderCell :UITableViewCell{
    let F = UIButton()
    let M = UIButton()
    let Unknown = UIButton()
    var theGender = 0
    init(gender:Int){
        theGender = gender
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "GenderCell")
        M.frame = CGRectMake(self.frame.width * (1 / 5) - 10, self.frame.height / 10, self.frame.width / 5, self.frame.height * 0.8)
        F.frame = CGRectMake(self.frame.width * (2 / 5), self.frame.height / 10, self.frame.width / 5, self.frame.height * 0.8)
        Unknown.frame = CGRectMake(self.frame.width * (3 / 5) + 10, self.frame.height / 10, self.frame.width / 5, self.frame.height * 0.8)

        F.setTitle("♀ 女", forState: .Normal)
        M.setTitle("♂ 男", forState: .Normal)
        Unknown.setTitle(" 保密 ", forState: .Normal)
        if gender == 0 {
            F.backgroundColor = UIColor.grayColor()
            M.backgroundColor = UIColor.lightGrayColor()
            Unknown.backgroundColor = UIColor.lightGrayColor()
        }
        if gender == 1 {
            M.backgroundColor = UIColor.grayColor()
            F.backgroundColor = UIColor.lightGrayColor()
            Unknown.backgroundColor = UIColor.lightGrayColor()
        }
        if gender == 2 {
            F.backgroundColor = UIColor.lightGrayColor()
            M.backgroundColor = UIColor.lightGrayColor()
            Unknown.backgroundColor = UIColor.grayColor()
        }
        M.addTarget(self, action: "touchM", forControlEvents: UIControlEvents.TouchUpInside)
        F.addTarget(self, action: "touchF", forControlEvents: .TouchUpInside)
        Unknown.addTarget(self, action: "touchUnknown", forControlEvents: .TouchUpInside)
        self.addSubview(Unknown)
        self.addSubview(M)
        self.addSubview(F)
    }
    func touchF(){
        theGender = 0
        F.backgroundColor = UIColor.grayColor()
        M.backgroundColor = UIColor.lightGrayColor()
          Unknown.backgroundColor = UIColor.lightGrayColor()
    }
    func touchM(){
        theGender = 1
        M.backgroundColor = UIColor.grayColor()
        F.backgroundColor = UIColor.lightGrayColor()
          Unknown.backgroundColor = UIColor.lightGrayColor()
    }
    func touchUnknown(){
        theGender = 2
        M.backgroundColor = UIColor.lightGrayColor()
        F.backgroundColor = UIColor.lightGrayColor()
        Unknown.backgroundColor = UIColor.grayColor()
    }
    
}
