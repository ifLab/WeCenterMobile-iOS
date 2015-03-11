//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/24.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData

class HomeViewController: UITableViewController {
    
    let count = 20
    var page = 1
    
    var user: User!
    var actions = [Action]()
    
    let actionTypes = [AnswerAction.self, QuestionPublishmentAction.self, QuestionFocusingAction.self, AnswerAgreementAction.self, ArticlePublishmentAction.self, ArticleAgreementAction.self]
    let identifiers = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell"]
    let nibNames = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell"]
    
    init(user: User) {
        super.init(style: .Plain)
        self.user = user
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_loadMoreControl = MSRLoadMoreControl()
        msr_loadMoreControl!.addTarget(self, action: "loadMore", forControlEvents: .ValueChanged)
        title = "首页" // Needs localization
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "List-Dots"), style: .Bordered, target: self, action: "showSidebar")
//        tableView.rowHeight = UITableViewAutomaticDimension
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.beginRefreshing()
        refresh()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(page * count, actions.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let action = actions[indexPath.row]
        let index = actionTypes.indexOfObject(action.classForCoder)
        if index >= identifiers.count {
            return UITableViewCell() // Needs specification
        }
        var cell: ActionCell! = tableView.dequeueReusableCellWithIdentifier(identifiers[index]) as? ActionCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(nibNames[index], owner: self, options: nil).first as! ActionCell
        }
        cell.userNameButton.addTarget(self, action: "pushUserViewController:", forControlEvents: .TouchUpInside)
        if let cell_ = cell as? QuestionPublishmentActionCell {
            cell_.questionTitleButton.addTarget(self, action: "pushQuestionViewController:", forControlEvents: .TouchUpInside)
        }
        cell.update(action: action)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let action = actions[indexPath.row]
        let index = actionTypes.indexOfObject(action.classForCoder)
        if index >= nibNames.count {
            return 40
        }
        struct _Static {
            static var cells = [String: ActionCell]()
            static var id: dispatch_once_t = 0
        }
        dispatch_once(&_Static.id) {
            for nibName in self.nibNames {
                _Static.cells[nibName] = (NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil).first as! ActionCell)
            }
        }
        let cell = _Static.cells[nibNames[index]]!
        cell.update(action: action)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
//        let className = NSStringFromClass(action.classForCoder).stringByReplacingOccurrencesOfString("WeCenterMobile.", withString: "", options: .CaseInsensitiveSearch, range: nil)
//        println("\(indexPath.row). \(action.user.name!), \(className): \(cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height)")
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.show(animated: true)
    }
    
    func pushUserViewController(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    
    func pushQuestionViewController(sender: UIButton) {
        if let question = sender.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    
    internal func refresh() {
        user.fetchRelatedActions(
            page: 1,
            count: count,
            success: {
                self.page = 1
                self.actions = (dataManager.fetchAll("Action", error: nil) as! [Action]).sorted() {
                    $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970
                }
//                for (i, user) in enumerate(map(self.actions, { $0.user }))  {
//                    user.fetchAvatar(
//                        success: {
//                            appDelegate.saveContext()
//                            let indexPath = NSIndexPath(forRow: i, inSection: 0)
//                            let cell: ActionCell? = self.tableView.cellForRowAtIndexPath(indexPath) as? ActionCell
//                            if cell != nil {
//                                self.tableView.beginUpdates()
//                                if cell?.userNameButton.msr_userInfo as? NSNumber == user.id {
//                                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//                                }
//                                self.tableView.endUpdates()
//                            }
//                        },
//                        failure: nil)
//                }
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            },
            failure: {
                error in
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            })
    }
    
    internal func loadMore() {
        user.fetchRelatedActions(
            page: page + 1,
            count: count,
            success: {
                ++self.page
                self.actions = (dataManager.fetchAll("Action", error: nil) as! [Action]).sorted() {
                    $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970
                }
                self.tableView.reloadData()
                self.msr_loadMoreControl!.endLoadingMore()
            },
            failure: {
                error in
                self.tableView.reloadData()
                self.msr_loadMoreControl!.endLoadingMore()
            })
    }
    
}