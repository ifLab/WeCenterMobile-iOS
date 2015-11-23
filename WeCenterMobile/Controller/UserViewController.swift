//
//  UserViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-20.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UserEditViewControllerDelegate {
    
    lazy var header: UserHeaderView = {
        let v =  NSBundle.mainBundle().loadNibNamed("UserHeaderView", owner: nil, options: nil).first as! UserHeaderView
        v.frame = CGRect(x: 0, y: 0, width: 0, height: v.maxHeight)
        v.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
        return v
    }()
    
    let bodyCellNibName = "UserBodyCell"
    let bodyCellReuseIdentifier = "UserBodyCell"
    let footerCellNibName = "UserFooterCell"
    let footerCellReuseIdentifier = "UserFooterCell"
    
    lazy var bodyView: UICollectionView = {
        [weak self] in
        let v = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        v.alwaysBounceVertical = true
        v.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        v.delaysContentTouches = false
        v.indicatorStyle = .White
        v.contentInset.top = UIApplication.sharedApplication().statusBarFrame.height
        v.scrollIndicatorInsets.top = self?.header.minHeight ?? 0
        v.contentOffset.y = -v.contentInset.top
        v.backgroundColor = UIColor.clearColor()
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    var user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(bodyView)
        bodyView.addSubview(header)
        view.backgroundColor = UIColor.msr_materialGray900()
        bodyView.frame = view.bounds
        header.frame.size.width = bodyView.bounds.width
        bodyView.registerNib(UINib(nibName: bodyCellNibName, bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: bodyCellReuseIdentifier)
        bodyView.registerNib(UINib(nibName: footerCellNibName, bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: footerCellReuseIdentifier)
        if msr_navigationController!.viewControllers.count == 1 {
            header.backButton.setImage(UIImage(named: "Navigation-Root"), forState: .Normal)
            header.backButton.addTarget(self, action: "didPressMenuButton", forControlEvents: .TouchUpInside)
        } else {
            header.backButton.addTarget(self, action: "didPressBackButton", forControlEvents: .TouchUpInside)
        }
        bodyView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        bodyView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        bodyView.msr_uiRefreshControl = UIRefreshControl()
        bodyView.msr_uiRefreshControl!.tintColor = UIColor.whiteColor()
        bodyView.msr_uiRefreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        msr_navigationBar!.hidden = true
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        bodyView.contentSize = CGSize(width: 1, height: 1000)
        bodyView.msr_uiRefreshControl?.beginRefreshing()
        refresh()
    }
    
    func refresh() {
        User.fetch(ID: user.id,
            success: {
                [weak self] user in
                self?.user = user
                self?.reloadData()
                self?.user.fetchProfile(
                    success: {
                        self?.reloadData()
                        self?.user.fetchAvatar(
                            forced: true,
                            success: {
                                self?.reloadData()
                                self?.bodyView.msr_uiRefreshControl?.endRefreshing()
                            },
                            failure: {
                                [weak self] error in
                                self?.bodyView.msr_uiRefreshControl?.endRefreshing()
                                return
                            })
                        return
                    },
                    failure: {
                        [weak self] error in
                        self?.bodyView.msr_uiRefreshControl?.endRefreshing()
                        return
                    })
                return
            },
            failure: {
                [weak self] error in
                self?.bodyView.msr_uiRefreshControl?.endRefreshing()
                return
            })
    }
    
    func reloadData() {
        bodyView.backgroundColor = TintColorFromColor(user.avatar?.msr_averageColorWithAccuracy(0.5)).colorWithAlphaComponent(0.3)
        header.update(user: user)
        bodyView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === bodyView {
            let offset = bodyView.contentOffset.y
            header.frame.size.height = floor(max(header.maxHeight - offset - UIApplication.sharedApplication().statusBarFrame.height, header.minHeight)) // The appearences of blur effect view will not correct unless it's height is an integer.
            header.frame.origin.y = offset
            bodyView.scrollIndicatorInsets.top = header.bounds.height
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return [6, 1][section]
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = bodyView.dequeueReusableCellWithReuseIdentifier(bodyCellReuseIdentifier, forIndexPath: indexPath) as! UserBodyCell
            let titles = ["提问", "回答", "文章", "话题", "关注中", "追随者"]
            let counts = [user.questionCount, user.answerCount, user.articleCount, user.topicFocusCount, user.followingCount, user.followerCount].map {
                return $0?.description ?? "0"
            }
            cell.titleLabel.text = titles[indexPath.item]
            cell.countLabel.text = counts[indexPath.item]
            return cell
        } else {
            let cell = bodyView.dequeueReusableCellWithReuseIdentifier(footerCellReuseIdentifier, forIndexPath: indexPath) as! UserFooterCell
            if user.isCurrentUser {
                cell.textLabel.text = "修改信息"
                cell.textLabel.textColor = UIColor.whiteColor()
                cell.activityIndicatorView.stopAnimating()
            } else {
                if let following = user.following {
                    cell.textLabel.text = following ? "已关注" : "关注"
                    cell.textLabel.textColor = following ? UIColor.lightTextColor() : UIColor.whiteColor()
                    cell.activityIndicatorView.stopAnimating()
                } else {
                    cell.textLabel.text = ""
                    cell.activityIndicatorView.startAnimating()
                }
            }
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            let length = collectionView.bounds.width / 3 - 2 / 3
            return CGSize(width: length, height: length)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: header.maxHeight - UIApplication.sharedApplication().statusBarFrame.height + 1, left: 0, bottom: 1, right: 0)
        } else {
            return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.item {
            case 0:
                msr_navigationController!.pushViewController(QuestionListViewController(user: user), animated: true)
                break
            case 1:
                msr_navigationController!.pushViewController(AnswerListViewController(user: user), animated: true)
                break
            case 2:
                msr_navigationController!.pushViewController(ArticleListViewController(user: user), animated: true)
                break
            case 3:
                msr_navigationController!.pushViewController(TopicListViewController(user: user), animated: true)
                break
            case 4:
                msr_navigationController!.pushViewController(UserListViewController(user: user, listType: .UserFollowing), animated: true)
                break
            case 5:
                msr_navigationController!.pushViewController(UserListViewController(user: user, listType: .UserFollower), animated: true)
                break
            default:
                break
            }
        } else {
            if user.isCurrentUser {
                let uevc = NSBundle.mainBundle().loadNibNamed("UserEditViewController", owner: nil, options: nil).first as! UserEditViewController
                uevc.delegate = self
                showDetailViewController(uevc, sender: self)
            } else {
                let following = user.following
                user.following = nil
                collectionView.reloadItemsAtIndexPaths([indexPath])
                user.toggleFollow(
                    success: {
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                        return
                    },
                    failure: {
                        [weak self] error in
                        self?.user.following = following
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                        return
                    })
            }
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return user.following != nil || user.isCurrentUser
        }
        return true
    }
    
    func didPressMenuButton() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    func didPressBackButton() {
        msr_navigationController!.popViewController(animated: true)
    }
    
    func userEditViewControllerDidUpdateUserProfile(uevc: UserEditViewController) {
        reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
