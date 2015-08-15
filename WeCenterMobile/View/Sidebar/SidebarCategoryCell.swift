//
//  SidebarCategoryCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/31.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class SidebarCategoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    var category: SidebarCategory?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        msr_scrollView?.delaysContentTouches = false
    }
    
    func update(#category: SidebarCategory) {
        self.category = category
        categoryImageView.image = imageFromSidebarCategory(category)
        categoryTitleLabel.text = localizedStringFromSidebarCategory(category)
        updateTheme()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateTheme() {
        let theme = SettingsManager.defaultManager.currentTheme
        categoryImageView.tintColor = theme.titleTextColor
        categoryTitleLabel.textColor = theme.titleTextColor
        selectedBackgroundView.backgroundColor = theme.highlightColor
    }
    
    override func prepareForReuse() {
        category = nil
    }
    
}
