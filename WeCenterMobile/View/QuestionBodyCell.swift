//
//  QuestionBodyCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class QuestionBodyCell: DTAttributedTextCell {
    init(question: Question?, reuseIdentifier: String!) {
        super.init(reuseIdentifier: reuseIdentifier)
        initialize()
        update(question: question)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    func initialize() {
        
    }
    func update(#question: Question?) {
        var HTMLString = ""
        if question?.body != nil {
            HTMLString = "<p style='padding: 5px'>\(question!.body!)</p>"
        }
        setHTMLString(HTMLString,
            options: [
                NSTextSizeMultiplierDocumentOption: 1,
                DTDefaultFontSize: 14,
                DTDefaultTextColor: UIColor.darkTextColor(),
                DTDefaultLinkColor: "purple",
                DTDefaultLinkHighlightColor: "red"
            ])
    }
}
