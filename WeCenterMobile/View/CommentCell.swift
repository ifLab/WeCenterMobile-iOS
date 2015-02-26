//
//  CommentCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/2/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyLabel.preferredMaxLayoutWidth = bodyLabel.bounds.width
    }
    
    func update(#answerComment: AnswerComment) {
        let comment = answerComment
        msr_userInfo = comment
        avatarButton.setImage(comment.user?.avatar, forState: .Normal)
        userNameLabel.text = comment.user?.name
        bodyLabel.text = comment.body! + comment.body!
    }
    
    func update(#articleComment: ArticleComment) {
        let comment = articleComment
        msr_userInfo = comment
        avatarButton.setImage(comment.user?.avatar, forState: .Normal)
        userNameLabel.text = comment.user?.name
        bodyLabel.text = comment.body
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let x = rect.origin.x
        let y = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height
        CGContextSaveGState(context)
        CGContextSetStrokeColorWithColor(context, UIColor.msr_materialGray400().CGColor)
        CGContextMoveToPoint(context, x, y + height)
        CGContextAddLineToPoint(context, x + width, y + height)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    
}
