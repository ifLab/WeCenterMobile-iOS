//
//  QuestionViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/8/21.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class QuestionViewController: UITableViewController, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {
    var question: Question!
    var answers: [Answer] {
        return (question.answers.allObjects ?? []) as [Answer]
    }
    var topics: [Topic] {
        return (question.topics.allObjects ?? []) as [Topic]
    }
    let identifiers = [
        "QUESTION_TITLE",
        "TOPIC",
        "QUESTION_BODY",
        "FOCUS",
        "ADD",
        "ANSWERS"
    ]
    let classes: [AnyClass] = [
        QuestionTitleCell.self,
        TopicTagListCell.self,
        QuestionBodyCell.self,
        QuestionFocusCell.self,
        AnswerAdditionCell.self,
        AnswerCell.self
    ]
    var questionFocusCell: QuestionFocusCell! = nil
    init(question: Question) {
        super.init(style: .Grouped)
        self.question = question
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        super.loadView()
        for i in 0..<identifiers.count {
            tableView.registerClass(classes[i], forCellReuseIdentifier: identifiers[i])
        }
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.contentInset.top -= 35
        tableView.contentOffset.y = 0
        tableView.separatorStyle = .None
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        Question.fetch(ID: question.id,
            success: {
                question in
                self.question = question
                self.tableView.reloadData()
            },
            failure: nil)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 5 {
            return question.answers.count ?? 0
        } else {
            return 1
        }
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = identifiers[indexPath.section]
        let cell: UITableViewCell! = tableView.cellForRowAtIndexPath(indexPath)
        switch indexPath.section {
        case 0:
            if cell == nil {
                return QuestionTitleCell(question: question, width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as QuestionTitleCell).update(question: question, width: tableView.bounds.width)
                return cell.bounds.height
            }
        case 1:
            if cell == nil {
                return TopicTagListCell(topics: topics, width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as TopicTagListCell).update(topics: topics, width: tableView.bounds.width)
                return cell.bounds.height
            }
        case 2:
            if cell == nil {
                return QuestionBodyCell(question: question, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as QuestionBodyCell).update(question: question)
                return (cell as QuestionBodyCell).requiredRowHeightInTableView(tableView)
            }
        case 3:
            if cell == nil {
                return QuestionFocusCell(question: question, answerCount: answers.count, width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as QuestionFocusCell).update(question: question, answerCount: answers.count, width: tableView.bounds.width)
                return cell.bounds.height
            }
        case 4:
            if cell == nil {
                return AnswerAdditionCell(reuseIdentifier: identifier, width: tableView.bounds.width).bounds.height
            } else {
                return cell.bounds.height
            }
        case 5:
            if cell == nil {
                return AnswerCell(answer: answers[indexPath.row], width: tableView.bounds.width, reuseIdentifier: identifier).bounds.height
            } else {
                (cell as AnswerCell).update(answer: answers[indexPath.row], width: tableView.bounds.width)
                return cell.bounds.height
            }
        default:
            return 0
        }
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1 || indexPath.section == 4 || indexPath.section == 5
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = identifiers[indexPath.section]
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? UITableViewCell
        switch indexPath.section {
        case 0:
            if cell == nil {
                cell = QuestionTitleCell(question: question, width: tableView.bounds.width, reuseIdentifier: identifier)
            } else {
                (cell as QuestionTitleCell).update(question: question, width: tableView.bounds.width)
            }
            break
        case 1:
            if cell == nil {
                cell = TopicTagListCell(topics: topics, width: tableView.bounds.width, reuseIdentifier: identifier)
            } else {
                (cell as TopicTagListCell).update(topics: topics, width: tableView.bounds.width)
            }
            break
        case 2:
            if cell == nil {
                cell = QuestionBodyCell(question: question, reuseIdentifier: identifier)
                NSNotificationCenter.defaultCenter().addObserverForName(DTAttributedTextContentViewDidFinishLayoutNotification, object: (cell as QuestionBodyCell).attributedTextContextView, queue: NSOperationQueue.mainQueue(), usingBlock: {
                    notification in
                    self.tableView.reloadData()
                })
            } else {
                (cell as QuestionBodyCell).update(question: question)
                (cell as QuestionBodyCell).textDelegate = self
            }
            break
        case 3:
            if cell == nil {
                questionFocusCell = QuestionFocusCell(question: question, answerCount: answers.count, width: tableView.bounds.width, reuseIdentifier: identifiers[3])
                cell = questionFocusCell
            } else {
                questionFocusCell = cell as? QuestionFocusCell
            }
            questionFocusCell.focusButton.addTarget(self, action: "toggleFocusQuestion:", forControlEvents: .TouchUpInside)
            questionFocusCell.update(question: question, answerCount: answers.count, width: tableView.bounds.width)
            break
        case 4:
            if cell == nil {
                cell = AnswerAdditionCell(reuseIdentifier: identifier, width: tableView.bounds.width)
            } else {
                (cell as AnswerAdditionCell).update(width: tableView.bounds.width)
            }
            break
        case 5:
            let answer = answers[indexPath.row]
            if cell == nil {
                cell = AnswerCell(answer: answer, width: tableView.bounds.width, reuseIdentifier: identifier)
            } else {
                (cell as AnswerCell).update(answer: answer, width: tableView.bounds.width)
            }
            let answerCell = cell as AnswerCell
            answerCell.avatarButton.setImage(nil, forState: .Normal)
            if answer.user?.avatar != nil {
                answerCell.avatarButton.setImage(answer.user!.avatar, forState: .Normal)
            } else {
                answer.user!.fetchAvatar(
                    success: {
                        if (answerCell.avatarButton.msr_userInfo as User).id == answer.user!.id {
                            answerCell.avatarButton.setImage(answer.user!.avatar, forState: .Normal)
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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            msr_navigationController!.pushViewController(TopicListViewController(topics: topics), animated: true)
            break
        case 5:
            msr_navigationController!.pushViewController(AnswerViewController(answerID: answers[indexPath.row].id), animated: true)
            break
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
            self.questionFocusCell.update(question: self.question, answerCount: self.question.answers.count, width: self.tableView.bounds.width)
        }
        question.toggleFocus(
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
