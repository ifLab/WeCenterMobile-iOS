//
//  QuestionTagListCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionTagListCell: UITableViewCell, ZFTokenFieldDataSource, ZFTokenFieldDelegate {
    
    @IBOutlet weak var tagsField: ZFTokenField!
    var topics = [Topic]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagsField.textField.enabled = false
        tagsField.delegate = self
        tagsField.dataSource = self
    }
    
    func update(#question: Question) {
        topics = sorted(question.topics) {
            $0.title! < $1.title
        }
        tagsField.reloadData()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - ZFTokenFieldDataSource
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 24
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        return UInt(topics.count)
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        let tag = topics[Int(index)].title!
        let label = UILabel()
        label.text = tag
        label.font = UIFont.systemFontOfSize(12)
        label.sizeToFit()
        label.frame.size.height = lineHeightForTokenInField(tagsField)
        label.frame.size.width += 20
        label.textAlignment = .Center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.backgroundColor = UIColor.msr_materialBrown600()
        label.textColor = UIColor.lightTextColor()
        return label
    }
    
    // MARK: - ZFTokenFieldDelegate
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 5
    }
    
}
