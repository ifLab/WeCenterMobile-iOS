//
//  UserBodyCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/10.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserBodyCell: UICollectionViewCell {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView!.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    }
    
}
