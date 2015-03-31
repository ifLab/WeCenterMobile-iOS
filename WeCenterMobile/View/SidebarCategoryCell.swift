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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    }
    
    func update(#image: UIImage, title: String) {
        categoryImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
        categoryTitleLabel.text = title
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}