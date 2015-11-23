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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagsField: ZFTokenField!
    @IBOutlet weak var tagsButton: UIButton!
    @IBOutlet weak var borderA: UIView!
    @IBOutlet weak var borderB: UIView!
    @IBOutlet weak var borderC: UIView!
    @IBOutlet weak var borderD: UIView!
    
    var topics = [Topic]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        tagsField.editable = false
        tagsField.delegate = self
        tagsField.dataSource = self
        let theme = SettingsManager.defaultManager.currentTheme
        tagsButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        containerView.backgroundColor = theme.backgroundColorB
        for v in [borderA, borderB, borderC, borderD] {
            v.backgroundColor = theme.borderColorA
        }
    }
    
    func update(question question: Question) {
        topics = question.topics.sort {
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
        let theme = SettingsManager.defaultManager.currentTheme
        label.backgroundColor = theme.backgroundColorA
        label.textColor = theme.subtitleTextColor
        return label
    }
    
}
