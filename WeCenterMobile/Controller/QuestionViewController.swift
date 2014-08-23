//
//  QuestionViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class QuestionViewController: UITableViewController {
    var questionID: NSNumber! = nil
    var data: (question: Question, topics: [Topic], answers: [Answer], users: [User])? = nil
    let identifiers = [
        "TOPIC",
        "QUESTION_BODY",
        "FOCUS",
        "ADD",
        "ANSWERS"
    ]
    init(questionID: NSNumber) {
        self.questionID = questionID
        super.init(style: .Grouped)
        tableView.registerClass(TopicTagListCell.self, forCellReuseIdentifier: identifiers[0])
        Question.fetchDataForQuestionViewControllerByID(questionID,
            strategy: .CacheOnly,
            success: {
                data in
                self.data = data
                self.tableView.reloadData()
                Question.fetchDataForQuestionViewControllerByID(questionID,
                    strategy: .NetworkOnly,
                    success: {
                        data in
                        self.data = data
                        self.tableView.reloadData()
                    },
                    failure: nil)
            },
            failure: nil)
    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return data!.answers.count
        } else {
            return 1
        }
    }
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        switch indexPath.section {
        case 0:
            return TopicTagListCell(topics: data?.topics ?? [], width: tableView.bounds.width, reuseIdentifier: "\(indexPath.section)").bounds.height
        default:
            return 0
        }
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let identifier = identifiers[indexPath.section]
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? UITableViewCell
        switch indexPath.section {
        case 0:
            if cell == nil {
                cell = TopicTagListCell(topics: data?.topics ?? [], width: tableView.bounds.width, reuseIdentifier: identifier)
            } else {
                (cell as TopicTagListCell).update(topics: data?.topics ?? [], width: tableView.bounds.width)
            }
            break
        default:
            break
        }
        return cell
    }
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let msr_navigationController = Msr.UI.navigationControllerOfViewController(self)
        switch indexPath.section {
        case 0:
            if data != nil {
                msr_navigationController!.pushViewController(TopicListViewController(topics: data!.topics), animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }
}
