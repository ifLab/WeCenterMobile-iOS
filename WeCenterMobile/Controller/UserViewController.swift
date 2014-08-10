//
//  UserViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-20.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UIScrollViewDelegate, UserEditDelegate {
    
    var topView = UIScrollView()
    var bottomView = UIScrollView()
    var avatarView = UIImageView()
    var nameLabel = UILabel()
    var hideableView = UIView()
    var signatureLabel = UILabel()
    var thankCountView = UserCountView()
    var likeCountView = UserCountView()
    var favoriteCountView = UserCountView()
    var agreementCountView = UserCountView()
    var topicButton = UserCountButton()
    var followingButton = UserCountButton()
    var followerButton = UserCountButton()
    var askedButton = UserCountButton()
    var answeredButton = UserCountButton()
    var articleButton = UserCountButton()
    var activityButton = UserCoverButton()
    
//    var likeView = UIImageView()
//    var likeCountLabel = UILabel()
//    var thankView = UIImageView()
//    var thankCountLabel = UILabel()
//    var favoriteView = UIImageView()
//    var favoriteCountLabel = UILabel()
    
    var userID: NSNumber!
    var user: User!
    var layouted: Bool = false
    
    init(userID: NSNumber) {
        self.userID = userID
        super.init()
        view = UIScrollView(frame: UIScreen.mainScreen().bounds)
        (view as UIScrollView).bounces = false
        
        view.addSubview(bottomView)
        view.addSubview(topView)
        topView.addSubview(avatarView)
        topView.addSubview(nameLabel)
        bottomView.addSubview(topicButton)
        bottomView.addSubview(followingButton)
        bottomView.addSubview(followerButton)
        bottomView.addSubview(articleButton)
        bottomView.addSubview(askedButton)
        bottomView.addSubview(answeredButton)
        bottomView.addSubview(hideableView)
        hideableView.addSubview(signatureLabel)
        hideableView.addSubview(thankCountView)
        hideableView.addSubview(likeCountView)
        hideableView.addSubview(favoriteCountView)
        hideableView.addSubview(agreementCountView)
        
        topView.frame = CGRect(x: 0, y: -(UINavigationController().navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height), width: view.bounds.width, height: 200)
        topView.backgroundColor = UIColor(RGB: 0x424242)
        topView.layer.shadowColor = UIColor.blackColor().CGColor
        topView.layer.shadowOpacity = true
        topView.layer.masksToBounds = false
        bottomView.frame = CGRect(x: 0, y: topView.frame.origin.y + topView.bounds.height, width: view.bounds.width, height: view.frame.height - topView.bounds.height)
        bottomView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        bottomView.alwaysBounceVertical = true
        bottomView.showsVerticalScrollIndicator = false
        bottomView.delegate = self
        bottomView.addGestureRecognizer(topView.panGestureRecognizer)
        avatarView.bounds.size = CGSize(width: 100, height: 100)
        avatarView.center.x = topView.center.x
        avatarView.frame.origin.y = 50
        avatarView.layer.cornerRadius = avatarView.bounds.width / 2
        avatarView.layer.masksToBounds = true
        nameLabel.frame = CGRect(x: 0, y: avatarView.frame.origin.y + avatarView.bounds.height + 20, width: topView.bounds.width, height: 26)
        nameLabel.font = UIFont.boldSystemFontOfSize(22)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = .Center
        hideableView.backgroundColor = topView.backgroundColor
        hideableView.frame = CGRect(x: 0, y: 0, width: bottomView.bounds.width, height: 50)
        hideableView.layer.shadowColor = UIColor.blackColor().CGColor
        hideableView.layer.shadowOpacity = true
        hideableView.layer.masksToBounds = false
        signatureLabel.font = UIFont.systemFontOfSize(16)
        signatureLabel.textColor = UIColor(RGB: 0xeeeeee)
        signatureLabel.numberOfLines = 0
        signatureLabel.textAlignment = .Center
        signatureLabel.frame = CGRect(x: 0, y: 0, width: hideableView.bounds.width, height: 0.01)
        signatureLabel.alpha = 0
//        var thankCountView = UserCountView()
//        var likeCountView = UserCountView()
//        var favoriteCountView = UserCountView()
//        var shareCountView = UserCountView()
        thankCountView.imageView.image = UIImage(named: "Love_icon").imageWithRenderingMode(.AlwaysTemplate)
        thankCountView.frame.origin = CGPoint(x: 0, y: 10)
        likeCountView.imageView.image = UIImage(named: "Like_icon").imageWithRenderingMode(.AlwaysTemplate)
        likeCountView.frame.origin = CGPoint(x: hideableView.bounds.width / 4, y: 10)
        favoriteCountView.imageView.image = UIImage(named: "Star_icon").imageWithRenderingMode(.AlwaysTemplate)
        favoriteCountView.frame.origin = CGPoint(x: hideableView.bounds.width * 2 / 4, y: 10)
        agreementCountView.imageView.image = UIImage(named: "Tick_icon").imageWithRenderingMode(.AlwaysTemplate)
        agreementCountView.frame.origin = CGPoint(x: hideableView.bounds.width * 3 / 4, y: 10)
        topicButton.frame.origin.x = 0
        followingButton.frame.origin.x = bottomView.bounds.width / 3
        followerButton.frame.origin.x = bottomView.bounds.width * 2 / 3
        articleButton.frame.origin = CGPoint(x: 0, y: topicButton.bounds.height)
        askedButton.frame.origin = CGPoint(x: bottomView.bounds.width / 3, y: followingButton.bounds.height)
        answeredButton.frame.origin = CGPoint(x: bottomView.bounds.width * 2 / 3, y: followerButton.bounds.height)
        if userID == appDelegate.currentUser!.id {
            topicButton.footerLabel.text = UserStrings["My topics"]
            followingButton.footerLabel.text = UserStrings["My following"]
            followerButton.footerLabel.text = UserStrings["My follower"]
        } else {
            topicButton.footerLabel.text = UserStrings["His Topics"]
            followingButton.footerLabel.text = UserStrings["His following"]
            followerButton.footerLabel.text = UserStrings["His follower"]
        }
        articleButton.footerLabel.text = UserStrings["Article"]
        askedButton.footerLabel.text = UserStrings["Asked"]
        answeredButton.footerLabel.text = UserStrings["Answered"]
        scrollViewDidScroll(bottomView)
        User.fetchUserByID(userID,
            strategy: .CacheOnly,
            success: {
                user in
                self.user = user
                self.view.setNeedsLayout()
                User.fetchUserByID(userID,
                    strategy: .NetworkFirst,
                    success: {
                        user in
                        self.user = user
                        self.view.setNeedsLayout()
                        user.fetchProfileUsingNetwork(
                            success: {
                                self.view.setNeedsLayout()
                            },
                            failure: {
                                error in
                        })
                    }, failure: nil)
            },
            failure: {
                error in
                User.fetchUserByID(userID,
                    strategy: .NetworkOnly,
                    success: {
                        user in
                        self.user = user
                        self.bottomView.setNeedsLayout()
                        user.fetchProfileUsingNetwork(
                            success: {
                                self.view.setNeedsLayout()
                            },
                            failure: {
                                error in
                        })
                    }, failure: nil)
        })
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(animated: Bool) {
        if appDelegate.currentUser?.avatarURL != nil {
            avatarView.setImageWithURL(NSURL(string: appDelegate.currentUser!.avatarURL))
        }
        msrNavigationBar.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        if !layouted {
            nameLabel.text = user.name
            if user.signature != nil {
                layouted = true
                signatureLabel.text = user.signature
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .BeginFromCurrentState, animations: {
                    let height = self.signatureLabel.sizeThatFits(CGSize(width: self.signatureLabel.frame.width, height: CGFloat.max)).height
                    self.signatureLabel.frame.size.height = height
                    self.hideableView.frame.size.height = height + 50
                    self.signatureLabel.alpha = 1
                    self.bottomView.contentSize = CGSize(width: self.bottomView.bounds.width, height: self.bottomView.bounds.height + self.hideableView.bounds.height)
                    self.topicButton.countLabel.text = "\(self.user.topicFocusCount!)"
                    self.followingButton.countLabel.text = "\(self.user.followingCount!)"
                    self.followerButton.countLabel.text = "\(self.user.followerCount!)"
                    self.articleButton.countLabel.font = UIFont.systemFontOfSize(10)
                    self.articleButton.countLabel.text = "没接口(╯`□′)╯(┻━┻"
                    self.askedButton.countLabel.text = "\(self.user.questionCount!)"
                    self.answeredButton.countLabel.text = "\(self.user.answerCount!)"
                    self.thankCountView.countLabel.text = "\(self.user.thankCount!)"
                    self.likeCountView.countLabel.text = "\(self.user.markCount!)"
                    self.favoriteCountView.countLabel.text = "\(self.user.answerFavoriteCount!)"
                    self.agreementCountView.countLabel.text = "\(self.user.agreementCount!)"
                    for subview in self.bottomView.subviews as [UIView] {
                        if subview !== self.hideableView {
                            subview.transform = CGAffineTransformMakeTranslation(0,  self.hideableView.frame.size.height)
                        }
                    }
                    for subview in self.hideableView.subviews as [UIView] {
                        if subview !== self.signatureLabel {
                            subview.transform = CGAffineTransformMakeTranslation(0,  height)
                        }
                    }
                    },
                    completion: {
                        finished in
                        self.bottomView.setContentOffset(CGPoint(x: 0, y: self.signatureLabel.bounds.height), animated: true)
                    })
            }
        }
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView!, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(bottomView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if scrollView === bottomView {
            if bottomView.contentOffset.y < 0 {
                topView.frame.size.height = 200 + -bottomView.contentOffset.y
                topView.layer.shadowRadius = 0
                topView.contentOffset.y = bottomView.contentOffset.y
                hideableView.layer.shadowRadius = 5
            } else {
                topView.frame.size.height = 200
                let percentage = min(bottomView.contentOffset.y, hideableView.bounds.height) / hideableView.bounds.height
                topView.layer.shadowRadius = pow(percentage, 0.2) * 5
                hideableView.layer.shadowRadius = pow(1 - percentage, 0.2) * 5
                topView.contentOffset.y = pow(percentage * pow(100, 2), 0.5) / 100 * 10
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView!) {
        if scrollView === bottomView {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .BeginFromCurrentState, animations: {
                if self.bottomView.contentOffset.y < self.signatureLabel.bounds.height / 2 {
                    self.bottomView.contentOffset.y = 0
                } else if self.bottomView.contentOffset.y < (self.signatureLabel.frame.height + self.hideableView.bounds.height) / 2 {
                    self.bottomView.contentOffset.y = self.signatureLabel.bounds.height
                } else {
                    self.bottomView.contentOffset.y = self.hideableView.bounds.height
                }
            }, completion: nil)
        }
    }
    
    func avatarDidPost(controller:UserEditViewController , image:UIImage) {
        
    }
    
    func nameDidPost(controller:UserEditViewController, name:String) {
        
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
