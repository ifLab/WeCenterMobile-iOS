//
//  QuestionViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/25.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionViewController: UITableViewController {
    
    let identifiers = ["QuestionDetailCell"]
    let nibNames = ["QuestionDetailCell"]
    
    var question: Question
    var answers = [Answer]()
    
    var questionDetailCell: QuestionDetailCell! = nil
    
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
        for i in 0..<identifiers.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
        println(questionDetailCell)
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
                }
                return
                
            }, failure: {
                error in
                println(error)
                return
            })
        NSNotificationCenter.defaultCenter().addObserverForName(DTAttributedTextContentViewDidFinishLayoutNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [weak self] notification in
            if let self_ = self {
                self_.questionDetailCell.questionBodyLabel.sizeToFit()
                self_.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("RELOADING")
        var cell: QuestionDetailBaseCell! = nil
        if indexPath.section == 0 {
            cell = questionDetailCell
        }
        cell.update(object: question)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        struct _Static {
            static var id: dispatch_once_t = 0
            static var cells = [String: QuestionDetailBaseCell]()
        }
        dispatch_once(&_Static.id) {
            for nibName in self.nibNames {
                _Static.cells[nibName] = (NSBundle.mainBundle().loadNibNamed(nibName, owner: self.tableView, options: nil).first as! QuestionDetailBaseCell)
            }
        }
        var cell: QuestionDetailBaseCell!
        if indexPath.section == 0 {
            if questionDetailCell == nil {
                questionDetailCell = NSBundle.mainBundle().loadNibNamed(nibNames[0], owner: tableView, options: nil).first as! QuestionDetailCell
            }
            cell = questionDetailCell
        } else {
            var cell = _Static.cells[nibNames[indexPath.section]]!
            cell = questionDetailCell
           // cell.update(object: /* object */)
        }
        return cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 1
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
