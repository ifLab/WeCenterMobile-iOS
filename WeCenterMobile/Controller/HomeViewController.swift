//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/24.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    let initStatusBarStyle: UIStatusBarStyle
    init(i: Int = 0, statusBarStyle: UIStatusBarStyle) {
        initStatusBarStyle = statusBarStyle
        super.init(nibName: nil, bundle: nil)
        title = i.description
        let color = UIColor.randomColor(true)
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        view.backgroundColor = UIColor(red: 1 - red * 0.2, green: 1 - green * 0.2, blue: 1 - blue * 0.2, alpha: 1)
    }
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "")
        switch indexPath.row {
        case 0:
            cell.textLabel.text = "Push View Controller"
            break
        case 1:
            cell.textLabel.text = "Pop View Controller"
            break
        case 2:
            cell.textLabel.text = "Pop To Root View Controller"
            break
        case 3:
            cell.textLabel.text = "Push 5 View Controllers"
            break
        case 4:
            cell.textLabel.text = "Pop 5 View Controllers"
            break
        case 5:
            cell.textLabel.text = "Replace Current View Controller"
            break
        case 6:
            cell.textLabel.text = "Replace & Push"
            break
        case 7:
            cell.textLabel.text = "Pop & Replace"
        case 8:
            cell.textLabel.text = "Pop & Push"
            cell.detailTextLabel.text = "Available When PopCount < ControllersCount"
        case 9:
            cell.textLabel.text = "Pop & Replace & Push"
            cell.detailTextLabel.text = "Available When PopCount = ControllersCount"
        default:
            break
        }
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        switch indexPath.row {
        case 0:
            let viewController = HomeViewController(i: title.toInt()! + 1, statusBarStyle: initStatusBarStyle)
            msrNavigationController.pushViewController(viewController, animated: true, completion: nil)
            break
        case 1:
            msrNavigationController.popViewController(true, completion: nil)
            break
        case 2:
            msrNavigationController.popToRootViewControllerAnimated(true, completion: nil)
            break
        case 3:
            var viewControllers = [UIViewController]()
            for i in 1...5 {
                viewControllers += HomeViewController(i: title.toInt()! + i, statusBarStyle: initStatusBarStyle)
            }
            msrNavigationController.pushViewControllers(viewControllers, animated: true, completion: nil)
            break
        case 4:
            var viewControllers = msrNavigationController.viewControllers
            for _ in 1...5 {
                viewControllers.removeLast()
            }
            msrNavigationController.setViewControllers(viewControllers, animated: true, completion: nil)
            break
        case 5:
            msrNavigationController.replaceCurrentViewControllerWithViewController(HomeViewController(i: title.toInt()!,  statusBarStyle: initStatusBarStyle), animated: true, completion: nil)
            break
        case 6:
            var viewControllers = msrNavigationController.viewControllers
            viewControllers.removeLast()
            for i in 0...1 {
                viewControllers += HomeViewController(i: title.toInt()! + i, statusBarStyle: initStatusBarStyle)
            }
            msrNavigationController.setViewControllers(viewControllers, animated: true, completion: nil)
            break
        case 7:
            var viewControllers = msrNavigationController.viewControllers
            for _ in 1...2 {
                viewControllers.removeLast()
            }
            viewControllers += HomeViewController(i: title.toInt()! - 1, statusBarStyle: initStatusBarStyle)
            msrNavigationController.setViewControllers(viewControllers, animated: true, completion: nil)
        case 8:
            var viewControllers = [msrNavigationController.viewControllers.firstOne]
            for i in 1...title.toInt()! {
                viewControllers += HomeViewController(i: i, statusBarStyle: initStatusBarStyle)
            }
            msrNavigationController.setViewControllers(viewControllers, animated: true, completion: nil)
        case 9:
            var viewControllers = [UIViewController]()
            for i in 0...title.toInt()! {
                viewControllers += HomeViewController(i: i, statusBarStyle: initStatusBarStyle)
            }
            msrNavigationController.setViewControllers(viewControllers, animated: true, completion: nil)
        default:
            break
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.fromRaw(Int(title.toInt()! + initStatusBarStyle.toRaw()) % 2)!
    }
}
