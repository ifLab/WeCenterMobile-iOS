//
//  SettingsViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/30.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var noImagesModeSwitch: UISwitch!
    @IBOutlet weak var nightModeSwitch: UISwitch!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var tintColorDisplayView: UIView!
    @IBOutlet weak var weiboAccountConnectionSwitch: UISwitch!
    @IBOutlet weak var qqAccountConnectionSwitch: UISwitch!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var cacheSizeLabel: UILabel!
    @IBOutlet weak var cacheSizeCalculationActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var clearCacheButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List"), style: .Plain, target: self, action: "showSidebar")
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        logoutButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        clearCacheButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        msr_navigationBar!.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    @IBAction func didPressLogoutButton() {
        logout()
    }
    
    func logout() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
