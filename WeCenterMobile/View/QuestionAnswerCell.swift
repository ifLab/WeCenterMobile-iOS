//
//  QuestionAnswerCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/18.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class QuestionAnswerCell: UITableViewCell {

    var questionButton = BFPaperButton()
    var questionLabel = UILabel()
    var answerButton = BFPaperButton()
    var answerLabel = UILabel()
    var userButton = BFPaperButton()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    func initialize() {
        contentView.addSubview(questionButton)
        contentView.addSubview(answerButton)
        contentView.addSubview(userButton)
        questionButton.addSubview(questionLabel)
        answerButton.addSubview(answerLabel)
        
        questionButton.exclusiveTouch = true
        questionButton.backgroundColor = UIColor.paperColorGray200()
        
        answerButton.exclusiveTouch = true
        answerButton.backgroundColor = UIColor.paperColorGray100()
        
        userButton.exclusiveTouch = true
        userButton.backgroundColor = UIColor.paperColorGray200()
        
        questionLabel.numberOfLines = 0
        
        answerLabel.numberOfLines = 4
    }
    func update(#data: (question: Question, answer: Answer, user: User), width: CGFloat) {
        let question = data.question
        let answer = data.answer
        let user = data.user
        
        questionButton.msrUserInfo = question.id
        answerButton.msrUserInfo = answer.id
        userButton.msrUserInfo = user.id
        
        questionLabel.text = question.title
        questionLabel.font = UIFont.boldSystemFontOfSize(16)
        questionLabel.frame = CGRect(origin: CGPoint(x: 10, y: 12), size: questionLabel.sizeThatFits(CGSize(width: width - 20, height: CGFloat.max)))
        
        questionButton.frame = CGRect(x: 0, y: 0, width: width, height: questionLabel.bounds.height + 24)
        
        userButton.frame = CGRect(x: 10, y: questionButton.frame.origin.y + questionButton.bounds.height + 10, width: 40, height: 40)
        userButton.layer.cornerRadius = userButton.bounds.width / 2
        userButton.layer.masksToBounds = true
        
        answerLabel.text = answer.body
        answerLabel.font = UIFont.systemFontOfSize(14)
        answerLabel.frame = CGRect(
            origin: CGPoint(x: userButton.frame.origin.x + userButton.bounds.width + 10, y: 10),
            size: answerLabel.sizeThatFits(CGSize(width: width - 20 - userButton.bounds.width - 10, height: CGFloat.max)))
        
        answerButton.frame = CGRect(x: 0, y: questionButton.frame.origin.y + questionButton.bounds.height, width: width, height: max(answerLabel.bounds.height, userButton.bounds.height) + 20)
        
        frame = CGRect(x: 0, y: 0, width: width, height: questionButton.bounds.height + answerButton.bounds.height)
    }
    
}
