//
//  QuestionBodyCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit
import WebKit

class QuestionBodyCell: BFPaperTableViewCell {
    let titleLabel = UILabel()
    let bodyView = WKWebView(frame: CGRectZero, configuration: WKWebViewConfiguration())
    init(question: Question, width: CGFloat, reuseIdentifier: String!) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    func initialize() {
        
    }
}
