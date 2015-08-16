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
    
    @IBOutlet weak var noImagesModeView: UIView!
    @IBOutlet weak var nightModeView: UIView!
    @IBOutlet weak var fontSizeView: UIView!
    @IBOutlet weak var tintColorView: UIView!
    @IBOutlet weak var weiboAccountConnectionView: UIView!
    @IBOutlet weak var qqAccountConnectionView: UIView!
    @IBOutlet weak var updateServerConfigurationsView: UIView!
    @IBOutlet weak var clearCacheView: UIView!
    
    @IBOutlet weak var noImagesModeLabel: UILabel!
    @IBOutlet weak var nightModeLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var tintColorLabel: UILabel!
    @IBOutlet weak var weiboAccountConnectionLabel: UILabel!
    @IBOutlet weak var qqAccountConnectionLabel: UILabel!
    @IBOutlet weak var updateServerConfigurationsLabel: UILabel!
    @IBOutlet weak var clearCacheLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-Root"), style: .Plain, target: self, action: "showSidebar")
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.contentViewController.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        logoutButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        clearCacheButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentThemeDidChange", name: CurrentThemeDidChangeNotificationName, object: nil)
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateTheme()
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
            let source = SettingsManager.defaultManager.currentTheme.name
            let target = source == "Night" ? "Day" : "Night"
            let configuration = configurations[target] as! NSDictionary
            let theme = Theme(name: target, configuration: configuration)
            SettingsManager.defaultManager.currentTheme = theme
        }
    }
    
    func currentThemeDidChange() {
        updateTheme()
    }
    
    func reloadData() {
        let manager = SettingsManager.defaultManager
        nightModeSwitch.on = manager.currentTheme.name == "Night"
    }
    
    func updateTheme() {
        let theme = SettingsManager.defaultManager.currentTheme
        msr_navigationBar!.barStyle = theme.navigationBarStyle /// @TODO: Wrong behaviour will occur if put it into the animation block. This might be produced by the reinstallation of navigation bar background view.
        msr_navigationBar!.tintColor = theme.navigationItemColor
        setNeedsStatusBarAppearanceUpdate()
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.backgroundColor = theme.backgroundColorA
        let views = [
            noImagesModeView,
            nightModeView,
            fontSizeView,
            tintColorView,
            weiboAccountConnectionView,
            qqAccountConnectionView,
            updateServerConfigurationsView,
            clearCacheView]
        for view in views {
            view.backgroundColor = theme.backgroundColorB
            view.msr_borderColor = theme.borderColorA
        }
        let labels = [
            noImagesModeLabel,
            nightModeLabel,
            fontSizeLabel,
            tintColorLabel,
            weiboAccountConnectionLabel,
            qqAccountConnectionLabel,
            updateServerConfigurationsLabel,
            clearCacheLabel]
        for label in labels {
            label.textColor = theme.titleTextColor
        }
        let switchs = [
            noImagesModeSwitch,
            nightModeSwitch,
            weiboAccountConnectionSwitch,
            qqAccountConnectionSwitch]
        for s in switchs {
            s.onTintColor = theme.controlColorA
            s.tintColor = theme.controlColorB
        }
        let sliders = [
            fontSizeSlider]
        for slider in sliders {
            slider.minimumTrackTintColor = theme.controlColorA
            slider.maximumTrackTintColor = theme.controlColorB
            slider.tintColor = theme.controlColorB
        }
        cacheSizeLabel.textColor = theme.subtitleTextColor
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
