//
//  UserFooterCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/10.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserFooterCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView!.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    }
    
}
