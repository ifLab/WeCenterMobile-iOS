//
//  QuestionBodyCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class QuestionBodyCell: DTAttributedTextCell {
    init(question: Question?, reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        update(question: question)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    func update(#question: Question?) {
        var HTMLString = ""
        if question?.body != nil {
            HTMLString = "<p style='padding: 5px'>\(question?.body ?? String())</p>"
        }
        setHTMLString(HTMLString,
            options: [
                NSTextSizeMultiplierDocumentOption: 1,
                DTDefaultFontSize: 14,
                DTDefaultTextColor: UIColor.msr_materialGray600(),
                DTDefaultLinkColor: UIColor.msr_materialBlue500(),
                DTDefaultLinkHighlightColor: UIColor.msr_materialPurple300(),
                DTDefaultLineHeightMultiplier: 1.5,
                DTDefaultLinkDecoration: false
            ])
    }
}
