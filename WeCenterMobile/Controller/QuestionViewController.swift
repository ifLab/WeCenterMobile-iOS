//
//  QuestionViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class QuestionViewController: UITableViewController, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {
    var questionID: NSNumber! = nil
    var data: (question: Question, topics: [Topic], answers: [Answer], users: [User])? = nil
    let identifiers = [
        "QUESTION_TITLE",
        "TOPIC",
        "QUESTION_BODY",
        "FOCUS",
        "ADD",
        "ANSWERS"
    ]
    var questionFocusCell: QuestionFocusCell! = nil
    init(questionID: NSNumber) {
        super.init(style: .Grouped)
        self.questionID = questionID
    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func loadView() {
        super.loadView()
        tableView.registerClass(QuestionTitleCell.self, forCellReuseIdentifier: identifiers[0])
        tableView.registerClass(TopicTagListCell.self, forCellReuseIdentifier: identifiers[1])
        tableView.registerClass(QuestionBodyCell.self, forCellReuseIdentifier: identifiers[2])
        tableView.registerClass(QuestionFocusCell.self, forCellReuseIdentifier: identifiers[3])
        tableView.registerClass(AnswerAdditionCell.self, forCellReuseIdentifier: identifiers[4])
        tableView.registerClass(AnswerCell.self, forCellReuseIdentifier: identifiers[5])
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.contentInset.top -= 35
        tableView.contentOffset.y = 0
        tableView.separatorStyle = .None
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Question.fetchDataForQuestionViewControllerByID(questionID,
            strategy: .CacheOnly,
            success: {
                data in
                self.data = data
                self.tableView.reloadData()
                Question.fetchDataForQuestionViewControllerByID(self.questionID,
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
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 6
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 5 {
            return data!.answers.count
        } else {
            return 1
        }
    }
    override func tableView(tableView: UITableView!, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let identifier = identifiers[indexPath.section]
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        switch indexPath.section {
        case 0:
            if cell == nil {
                return QuestionTitleCell(question: data?.question, width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as QuestionTitleCell).update(question: data?.question, width: tableView.bounds.width)
                return cell!.bounds.height
            }
        case 1:
            if cell == nil {
                return TopicTagListCell(topics: data?.topics ?? [], width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as TopicTagListCell).update(topics: data?.topics ?? [], width: tableView.bounds.width)
                return cell!.bounds.height
            }
        case 2:
            if cell == nil {
                return QuestionBodyCell(question: data?.question, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as QuestionBodyCell).update(question: data?.question)
                return (cell as QuestionBodyCell).requiredRowHeightInTableView(tableView)
            }
        case 3:
            if cell == nil {
                return QuestionFocusCell(question: data?.question, answerCount: data?.answers.count, width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as QuestionFocusCell).update(question: data?.question, answerCount: data?.answers.count, width: tableView.bounds.width)
                return cell!.bounds.height
            }
        case 4:
            if cell == nil {
                return AnswerAdditionCell(reuseIdentifier: identifier, width: tableView.bounds.width).bounds.height
            } else {
                return cell!.bounds.height
            }
        case 5:
            if cell == nil {
                return AnswerCell(answer: data?.answers[indexPath.row], user: data?.users[indexPath.row], width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as AnswerCell).update(answer: data?.answers[indexPath.row], user: data?.users[indexPath.row], width: tableView.bounds.width)
                return cell!.bounds.height
            }
        default:
            return 0
        }
    }
    override func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return indexPath.section == 1 || indexPath.section == 4 || indexPath.section == 5
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let identifier = identifiers[indexPath.section]
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? UITableViewCell
        switch indexPath.section {
        case 0:
            if cell == nil {
                cell = QuestionTitleCell(question: data?.question, width: tableView.bounds.width, reuseIdentifier: identifier)
            } else {
                (cell as QuestionTitleCell).update(question: data?.question, width: tableView.bounds.width)
            }
            break
        case 1:
            if cell == nil {
                cell = TopicTagListCell(topics: data?.topics ?? [], width: tableView.bounds.width, reuseIdentifier: identifier)
            } else {
                (cell as TopicTagListCell).update(topics: data?.topics ?? [], width: tableView.bounds.width)
            }
            break
        case 2:
            if cell == nil {
                cell = QuestionBodyCell(question: data?.question, reuseIdentifier: identifier)
                NSNotificationCenter.defaultCenter().addObserverForName(DTAttributedTextContentViewDidFinishLayoutNotification, object: (cell as QuestionBodyCell).attributedTextContextView, queue: NSOperationQueue.mainQueue(), usingBlock: {
                    notification in
                    println("?")
                    self.tableView.reloadData()
                })
            } else {
                (cell as QuestionBodyCell).update(question: data?.question)
                (cell as QuestionBodyCell).textDelegate = self
            }
            break
        case 3:
            if cell == nil {
                questionFocusCell = QuestionFocusCell(question: data?.question, answerCount: data?.answers.count, width: tableView.bounds.width, reuseIdentifier: identifiers[3])
                cell = questionFocusCell
            } else {
                questionFocusCell = cell as? QuestionFocusCell
            }
            questionFocusCell.focusButton.addTarget(self, action: "toggleFocusQuestion:", forControlEvents: .TouchUpInside)
            questionFocusCell.update(question: data?.question, answerCount: data?.answers.count, width: tableView.bounds.width)
            break
        case 4:
            if cell == nil {
                cell = AnswerAdditionCell(reuseIdentifier: identifier, width: tableView.bounds.width)
            } else {
                (cell as AnswerAdditionCell).update(width: tableView.bounds.width)
            }
            break
        case 5:
            let answer = data?.answers[indexPath.row]
            let user = data?.users[indexPath.row]
            if cell == nil {
                cell = AnswerCell(answer: answer, user: user, width: tableView.bounds.width, reuseIdentifier: identifier)
            } else {
                (cell as AnswerCell).update(answer: answer, user: user, width: tableView.bounds.width)
            }
            let answerCell = cell as AnswerCell
            answerCell.avatarButton.setImage(nil, forState: .Normal)
            if user?.avatar != nil {
                answerCell.avatarButton.setImage(user!.avatar, forState: .Normal)
            } else {
                user?.fetchAvatarImage(
                    success: {
                        if answerCell.avatarButton.tag == user!.id {
                            answerCell.avatarButton.setImage(user!.avatar, forState: .Normal)
                        }
                    },
                    failure: nil)
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
        case 1:
            if data != nil {
                msr_navigationController!.pushViewController(TopicListViewController(topics: data!.topics), animated: true, completion: nil)
            }
            break
        case 5:
            if data != nil {
                msr_navigationController!.pushViewController(AnswerViewController(answerID: data!.answers[indexPath.row].id), animated: true, completion: nil)
            }
        default:
            break
        }
    }
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if let imageAttachment = attachment as? DTImageTextAttachment {
            let imageView = DTLazyImageView(frame: frame)
            imageView.shouldShowProgressiveDownload = true
            imageView.image = imageAttachment.image
            imageView.url = imageAttachment.contentURL
            imageView.delegate = self
            return imageView
        }
        return nil
    }
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let predicate = NSPredicate(format: "contentURL == %@", lazyImageView.url)
        var didUpdate = false
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as DTAttributedTextCell
        for attachment in cell.attributedTextContextView.layoutFrame.textAttachmentsWithPredicate(predicate) as [DTTextAttachment] {
            if attachment.originalSize == CGSizeZero {
                attachment.originalSize = sizeWithImageSize(size)
                didUpdate = true
            }
        }
        if didUpdate {
            cell.attributedTextContextView.relayoutText()
            tableView.reloadData() // ???
        }
    }
    func toggleFocusQuestion(focusButton: UIButton) {
        questionFocusCell.focusButtonState = .Loading
        let update: () -> Void = {
            self.questionFocusCell.update(question: self.data?.question, answerCount: self.data?.answers.count, width: self.tableView.bounds.width)
        }
        data?.question.toggleFocus(
            success: update,
            failure: {
                error in
                update()
            })
    }
    private func sizeWithImageSize(size: CGSize) -> CGSize {
        let maxWidth = view.bounds.width - 20
        if size.width > maxWidth {
            let width = maxWidth
            let height = size.height * (width / size.width)
            return CGSize(width: width, height: height)
        } else {
            return size
        }
    }
}
