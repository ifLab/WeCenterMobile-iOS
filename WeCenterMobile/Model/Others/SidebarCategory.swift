//
//  SidebarCategory.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/8/15.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

enum SidebarCategory: String {
    case User = "User"
    case Home = "Home"
    case Explore = "Explore"
    case Drafts = "Drafts"
    case Search = "Search"
    case ReadingList = "ReadingList"
    case History = "History"
    case Settings = "Settings"
    case About = "About"
    static var allValues: [SidebarCategory] = [
        .User,
        .Home,
        .Explore,
//        .Drafts,
        .Search,
//        .ReadingList,
//        .History,
        .Settings,
        .About]
}

func localizedStringFromSidebarCategory(category: SidebarCategory) -> String {
    let data: [SidebarCategory: String] = [
        .User: "个人中心",
        .Home: "首页",
        .Explore: "发现",
        .Drafts: "草稿",
        .Search: "搜索",
        .ReadingList: "阅读列表",
        .History: "历史记录",
        .Settings: "设置",
        .About: "关于"]
    return data[category]!
}

func imageFromSidebarCategory(category: SidebarCategory) -> UIImage {
    return UIImage(named: "Sidebar-" + category.rawValue)!
}
