//
//  QuestionViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionViewController: UITableViewController {
    
    var question: Question {
        didSet {
            let defaultDate = NSDate(timeIntervalSince1970: 0)
            answers = sorted(question.answers) { ($0.date ?? defaultDate).timeIntervalSince1970 >= ($1.date ?? defaultDate).timeIntervalSince1970 }
        }
    }
    var answers = [Answer]()
    
    let answerCellIdentifier = "AnswerCell"
    let answerCellNibName = "AnswerCell"
    
    lazy var questionDetailCell: QuestionDetailCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("QuestionDetailCell", owner: self?.tableView, options: nil).first as! QuestionDetailCell
    }()
    lazy var answerAdditionCell: AnswerAdditionCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("AnswerAdditionCell", owner: self?.tableView, options: nil).first as! AnswerAdditionCell
    }()
    
    init(question: Question) {
        self.question = question
        super.init(style: .Plain)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        tableView.backgroundColor = UIColor.msr_materialBrown900()
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: answerCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: answerCellIdentifier)
        title = "问题详情" // Needs localization
        msr_navigationBar!.barStyle = .Black
        msr_navigationBar!.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        Question.fetch(
            ID: question.id,
            success: {
                [weak self] question in
                if let self_ = self {
                    self_.question = question
                    self_.tableView.reloadData()
                    if let user = question.user {
                        user.fetchProfile(
                            success: {
                                self_.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
                            },
                            failure: {
                                error in
                                NSLog("%@, %@, %@", __FILE__, __LINE__, __FUNCTION__, error)
                                return
                            })
                    }
                }
                return
            }, failure: {
                error in
                NSLog("%@, %@, %@", __FILE__, __LINE__, __FUNCTION__, error)
                return
            })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 1, answers.count][section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            questionDetailCell.update(object: question)
            return questionDetailCell
        } else if indexPath.section == 1 {
            return answerAdditionCell
        } else {
            let answerCell = tableView.dequeueReusableCellWithIdentifier(answerCellIdentifier, forIndexPath: indexPath) as! AnswerCell
            answerCell.update(object: answers[indexPath.row])
            return answerCell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        struct _Static {
            static var id: dispatch_once_t = 0
            static var answerCell: AnswerCell!
        }
        dispatch_once(&_Static.id) {
            [weak self] in
            if let self_ = self {
                _Static.answerCell = NSBundle.mainBundle().loadNibNamed(self_.answerCellNibName, owner: self_.tableView, options: nil).first as! AnswerCell
            }
        }
        var cell: UITableViewCell!
        if indexPath.section == 0 {
            questionDetailCell.update(object: question)
            cell = questionDetailCell
        } else if indexPath.section == 1 {
            cell = answerAdditionCell
        } else {
            _Static.answerCell.update(object: answers[indexPath.row])
            cell = _Static.answerCell
        }
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 1
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
