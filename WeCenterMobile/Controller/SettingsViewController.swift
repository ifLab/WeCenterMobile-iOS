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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTheme", name: CurrentThemeDidChangeNotificationName, object: nil)
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
    
    @IBAction func toggleNightTheme(sender: UISwitch) {
        if sender === nightModeSwitch {
            let path = NSBundle.mainBundle().pathForResource("Themes", ofType: "plist")!
            let configurations = NSDictionary(contentsOfFile: path)!
            let configuration = configurations[nightModeSwitch.on ? "Night" : "Day"] as! NSDictionary
            let theme = Theme(configuration: configuration)!
            SettingsManager.defaultManager.currentTheme = theme
        }
    }
    
    func updateTheme() {
        let theme = SettingsManager.defaultManager.currentTheme
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.7,
            options: .BeginFromCurrentState,
            animations: {
                [weak self] in
                if let self_ = self {
                    self_.tableView.backgroundColor = theme.backgroundColorA
                }
            },
            completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
