//
//  ArticleFooterView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleFooterView: UIToolbar {
    
    @IBOutlet weak var shareItem: UIBarButtonItem!
    @IBOutlet weak var agreeItem: UIBarButtonItem!
    @IBOutlet weak var agreementCountItem: UIBarButtonItem!
    @IBOutlet weak var disagreeItem: UIBarButtonItem!
    @IBOutlet weak var commentItem: UIBarButtonItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        agreementCountItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)
    }
    
    func update(#dataObject: ArticleViewControllerPresentable) {
        agreementCountItem.title = dataObject.agreementCount?.description ?? "-"
    }
    
}
