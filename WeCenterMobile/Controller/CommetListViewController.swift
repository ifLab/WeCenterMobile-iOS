//
//  CommetListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/4.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class CommentListViewController: UITableViewController {
    var answerID: NSNumber
    var answer: Answer {
        return Answer.get(ID: answerID, error: nil)!
    }
    init(answerID: NSNumber) {
        self.answerID = answerID
        super.init(style: .Plain)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}