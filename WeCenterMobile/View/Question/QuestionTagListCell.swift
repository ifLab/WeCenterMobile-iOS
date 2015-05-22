//
//  QuestionTagListCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import ZFTokenField

class QuestionTagListCell: UITableViewCell, ZFTokenFieldDataSource, ZFTokenFieldDelegate {
    
    @IBOutlet weak var tagsField: ZFTokenField!
    @IBOutlet weak var tagsButton: UIButton!
    var topics = [Topic]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        tagsField.editable = false
        tagsField.delegate = self
        tagsField.dataSource = self
        tagsButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func update(#question: Question) {
        topics = sorted(question.topics) {
            $0.title! < $1.title
        }
        tagsField.reloadData()
        tagsButton.msr_userInfo = topics
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - ZFTokenFieldDataSource
    
    func lineHeightForTokenField(tokenField: ZFTokenField!) -> CGFloat {
        return 24
    }
    
    func tokenMarginForTokenField(tokenField: ZFTokenField!) -> CGFloat {
        return 5
    }
    
    func numberOfTokensInTokenField(tokenField: ZFTokenField!) -> Int {
        return topics.count
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: Int) -> UIView! {
        let tag = topics[index].title!
        let label = UILabel()
        label.text = tag
        label.font = UIFont.systemFontOfSize(12)
        label.sizeToFit()
        label.frame.size.height = lineHeightForTokenField(tagsField)
        label.frame.size.width += 20
        label.textAlignment = .Center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.backgroundColor = UIColor.msr_materialGray200()
        label.textColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        return label
    }
    
}
