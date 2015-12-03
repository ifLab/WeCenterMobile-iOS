//
//  ArticleFooterView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

let normalAgreeImage = UIImage(named: "Evaluation-Like-Normal")
let highlightedAgreeImage = UIImage(named: "Evaluation-Like-Highlighted")
let normalDisagreeImage = UIImage(named: "Evaluation-Dislike-Normal")
let highlightedDisagreeImage = UIImage(named: "Evaluation-Dislike-Highlighted")

class ArticleFooterView: UIToolbar {
    
    @IBOutlet weak var shareItem: UIBarButtonItem!
    @IBOutlet weak var agreeItem: UIBarButtonItem!
    @IBOutlet weak var agreementCountItem: UIBarButtonItem!
    @IBOutlet weak var disagreeItem: UIBarButtonItem!
    @IBOutlet weak var commentItem: UIBarButtonItem!
    @IBOutlet weak var separatorAItem: UIBarButtonItem!
    @IBOutlet weak var separatorBItem: UIBarButtonItem!
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .White)
        let theme = SettingsManager.defaultManager.currentTheme
        v.color = theme.toolbarItemColor
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true
        v.stopAnimating()
        return v
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        barStyle = theme.toolbarStyle
        tintColor = theme.toolbarItemColor
        agreementCountItem.setTitleTextAttributes([
                NSForegroundColorAttributeName: theme.toolbarItemColor,
                NSFontAttributeName: UIFont.systemFontOfSize(14)],
            forState: .Normal)
        for v in [separatorAItem, separatorBItem] {
            v.customView!.backgroundColor = theme.borderColorA
        }
        for item in items ?? [] {
            item.tintColor = theme.toolbarItemColor
        }
        let s = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        s.alignment = .Center
        addSubview(activityIndicatorView)
        activityIndicatorView.msr_addCenterConstraintsToSuperview()
    }
    
    func update(dataObject dataObject: ArticleViewControllerPresentable) {
        if let count = dataObject.agreementCount {
            agreeItem.enabled = true
            disagreeItem.enabled = true
            agreementCountItem.title = "\(count)"
            activityIndicatorView.stopAnimating()
        } else {
            agreeItem.enabled = false
            disagreeItem.enabled = false
            agreementCountItem.title = ""
            activityIndicatorView.startAnimating()
        }
        agreeItem.image = dataObject.evaluationRawValue?.integerValue == Evaluation.Up.rawValue ? highlightedAgreeImage : normalAgreeImage
        disagreeItem.image = dataObject.evaluationRawValue?.integerValue == Evaluation.Down.rawValue ? highlightedDisagreeImage: normalDisagreeImage
    }
    
}
