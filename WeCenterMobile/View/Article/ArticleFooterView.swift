//
//  ArticleFooterView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

let normalAgreeImage = UIImage(named: "Like-Normal")
let highlightedAgreeImage = UIImage(named: "Like-Highlighted")
let normalDisagreeImage = UIImage(named: "Dislike-Normal")
let highlightedDisagreeImage = UIImage(named: "Dislike-Highlighted")

class ArticleFooterView: UIToolbar {
    
    @IBOutlet weak var shareItem: UIBarButtonItem!
    @IBOutlet weak var agreeItem: UIBarButtonItem!
    @IBOutlet weak var agreementCountItem: UIBarButtonItem!
    @IBOutlet weak var disagreeItem: UIBarButtonItem!
    @IBOutlet weak var commentItem: UIBarButtonItem!
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        aiv.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        aiv.stopAnimating()
        return aiv
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let s = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        s.alignment = .Center
        agreementCountItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)
        addSubview(activityIndicatorView)
        activityIndicatorView.msr_addCenterConstraintsToSuperview()
    }
    
    func update(#dataObject: ArticleViewControllerPresentable) {
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
