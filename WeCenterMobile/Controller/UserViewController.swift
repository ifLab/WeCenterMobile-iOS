//
//  UserViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-20.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UIScrollViewDelegate {
    
    enum AvatarButtonState {
        case Normal
        case NotFollowing
        case Following
    }
    
    var topView = UIScrollView()
    var bottomView = UIScrollView()
    var avatarButton = UIButton()
    var avatarButtonState = AvatarButtonState.Normal
    var avatarButtonTimer: NSTimer? = nil
    var avatarActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var nameLabel = UILabel()
    var hideableView = UIView()
    var signatureLabel = UILabel()
    var thankCountView = UserCountView()
    var likeCountView = UserCountView()
    var favoriteCountView = UserCountView()
    var agreementCountView = UserCountView()
    var topicButton = RectangleCountButton()
    var followingButton = RectangleCountButton()
    var followerButton = RectangleCountButton()
    var askedButton = RectangleCountButton()
    var answeredButton = RectangleCountButton()
    var articleButton = RectangleCountButton()
    
    var user: User
    var needsToBeRefreshed: Bool = false
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(bottomView)
        view.addSubview(topView)
        topView.addSubview(avatarButton)
        topView.addSubview(avatarActivityIndicatorView)
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
        topView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        topView.backgroundColor = UIColor.msr_materialGray300()
        topView.delaysContentTouches = false
        topView.layer.masksToBounds = false
        bottomView.frame = CGRect(x: 0, y: topView.frame.origin.y + topView.bounds.height, width: view.bounds.width, height: view.frame.height - topView.bounds.height)
        bottomView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        bottomView.alwaysBounceVertical = true
        bottomView.showsVerticalScrollIndicator = false
        bottomView.delegate = self
        bottomView.addGestureRecognizer(topView.panGestureRecognizer)
        avatarButton.bounds.size = CGSize(width: 100, height: 100)
        avatarButton.center.x = topView.center.x
        avatarButton.frame.origin.y = 50
        avatarButton.layer.cornerRadius = avatarButton.bounds.width / 2
        avatarButton.layer.masksToBounds = true
        avatarButton.addTarget(self, action: "toggleAvatarButtonImage", forControlEvents: .TouchUpInside)
        avatarButton.addTarget(self, action: "delayHidingAvatarButtonImage", forControlEvents: .TouchDown)
        avatarButton.imageView!.frame = avatarButton.bounds
        avatarButton.imageView!.alpha = 0
        avatarActivityIndicatorView.frame = avatarButton.frame
        avatarActivityIndicatorView.userInteractionEnabled = false
        nameLabel.frame = CGRect(x: 0, y: avatarButton.frame.origin.y + avatarButton.bounds.height + 20, width: topView.bounds.width, height: 26)
        nameLabel.font = UIFont.boldSystemFontOfSize(22)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.textAlignment = .Center
        hideableView.backgroundColor = topView.backgroundColor
        hideableView.frame = CGRect(x: 0, y: 0, width: bottomView.bounds.width, height: 0.01)
        hideableView.layer.masksToBounds = false
        signatureLabel.font = UIFont.systemFontOfSize(16)
        signatureLabel.textColor = UIColor.msr_materialGray900()
        signatureLabel.numberOfLines = 0
        signatureLabel.textAlignment = .Center
        signatureLabel.frame = CGRect(x: 0, y: 0, width: hideableView.bounds.width, height: 0.01)
        signatureLabel.alpha = 0
        thankCountView.imageView.image = UIImage(named: "Love_icon")!.imageWithRenderingMode(.AlwaysTemplate)
        thankCountView.frame.origin = CGPoint(x: 0, y: 10)
        likeCountView.imageView.image = UIImage(named: "Like_icon")!.imageWithRenderingMode(.AlwaysTemplate)
        likeCountView.frame.origin = CGPoint(x: hideableView.bounds.width / 4, y: 10)
        favoriteCountView.imageView.image = UIImage(named: "Star_icon")!.imageWithRenderingMode(.AlwaysTemplate)
        favoriteCountView.frame.origin = CGPoint(x: hideableView.bounds.width * 2 / 4, y: 10)
        agreementCountView.imageView.image = UIImage(named: "Tick_icon")!.imageWithRenderingMode(.AlwaysTemplate)
        agreementCountView.frame.origin = CGPoint(x: hideableView.bounds.width * 3 / 4, y: 10)
        topicButton.frame.origin.x = 0
        followingButton.frame.origin.x = bottomView.bounds.width / 3
        followerButton.frame.origin.x = bottomView.bounds.width * 2 / 3
        articleButton.frame.origin = CGPoint(x: 0, y: topicButton.bounds.height)
        askedButton.frame.origin = CGPoint(x: bottomView.bounds.width / 3, y: followingButton.bounds.height)
        answeredButton.frame.origin = CGPoint(x: bottomView.bounds.width * 2 / 3, y: followerButton.bounds.height)
        topicButton.alpha = 0
        followingButton.alpha = 0
        followerButton.alpha = 0
        articleButton.alpha = 0
        askedButton.alpha = 0
        answeredButton.alpha = 0
        topicButton.addTarget(self, action: "pushTopicListViewController", forControlEvents: .TouchUpInside)
        followerButton.addTarget(self, action: "pushFollowerViewController", forControlEvents: .TouchUpInside)
        followingButton.addTarget(self, action: "pushFollowingViewController", forControlEvents: .TouchUpInside)
        askedButton.addTarget(self, action: "pushQuestionViewController", forControlEvents: .TouchUpInside)
        for subview in hideableView.subviews as! [UIView] {
            subview.alpha = 0
        }
        if user.id == appDelegate.currentUser!.id {
            topicButton.footerLabel.text = userStrings("My topics")
            followingButton.footerLabel.text = userStrings("My following")
            followerButton.footerLabel.text = userStrings("My follower")
        } else {
            topicButton.footerLabel.text = userStrings("His topics")
            followingButton.footerLabel.text = userStrings("His following")
            followerButton.footerLabel.text = userStrings("His follower")
        }
        articleButton.footerLabel.text = userStrings("Article")
        askedButton.footerLabel.text = userStrings("Asked")
        answeredButton.footerLabel.text = userStrings("Answered")
        scrollViewDidScroll(bottomView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        needsToBeRefreshed = true
        view.setNeedsLayout()
        User.fetch(ID: user.id,
            success: {
                user in
                self.user = user
                self.needsToBeRefreshed = true
                self.view.setNeedsLayout()
                self.user.fetchProfile(
                    success: {
                        self.needsToBeRefreshed = true
                        self.view.setNeedsLayout()
                    },
                    failure: nil)
            },
            failure: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        msr_navigationBar!.hidden = true
        view.frame = msr_navigationController!.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        if needsToBeRefreshed {
            needsToBeRefreshed = false
            if user.name != nil {
                nameLabel.text = user.name
            }
            if user.avatarURL != nil {
                avatarButton.setBackgroundImageForState(.Normal, withURL: NSURL(string: user.avatarURL!), placeholderImage: avatarButton.backgroundImageForState(.Normal))
            }
            switch user.gender {
            case .Some(.Male):
                nameLabel.text! += " ♂"
                break
            case .Some(.Female):
                nameLabel.text! += " ♀"
                break
            default:
                break
            }
            if user.signature != nil {
                signatureLabel.text = user.signature
            }
            if user.topicFocusCount != nil {
                topicButton.countLabel.text = "\(user.topicFocusCount!)"
            }
            if user.followingCount != nil {
                followingButton.countLabel.text = "\(user.followingCount!)"
            }
            if user.followerCount != nil {
                followerButton.countLabel.text = "\(user.followerCount!)"
            }
            articleButton.countLabel.font = UIFont.systemFontOfSize(10)
            articleButton.countLabel.text = "没接口(╯`□′)╯(┻━┻"
            if user.questionCount != nil {
                askedButton.countLabel.text = "\(user.questionCount!)"
            }
            if user.answerCount != nil {
                answeredButton.countLabel.text = "\(user.answerCount!)"
            }
            if user.thankCount != nil {
                thankCountView.countLabel.text = "\(user.thankCount!)"
            }
            if user.markCount != nil {
                likeCountView.countLabel.text = "\(user.markCount!)"
            }
            if user.answerFavoriteCount != nil {
                favoriteCountView.countLabel.text = "\(user.answerFavoriteCount!)"
            }
            if user.agreementCount != nil {
                agreementCountView.countLabel.text = "\(user.agreementCount!)"
            }
            let height = self.signatureLabel.sizeThatFits(CGSize(width: self.signatureLabel.frame.width, height: CGFloat.max)).height
            self.signatureLabel.frame.size.height = height
            self.hideableView.frame.size.height = height + 50
            self.signatureLabel.alpha = 1
            self.bottomView.contentSize = CGSize(width: self.bottomView.bounds.width, height: self.bottomView.bounds.height + self.hideableView.bounds.height)
            self.topicButton.alpha = 1
            self.followingButton.alpha = 1
            self.followerButton.alpha = 1
            self.articleButton.alpha = 1
            self.askedButton.alpha = 1
            self.answeredButton.alpha = 1
            for subview in self.hideableView.subviews as! [UIView] {
                subview.alpha = 1
            }
            for subview in self.bottomView.subviews as! [UIView] {
                if subview !== self.hideableView {
                    subview.transform = CGAffineTransformMakeTranslation(0, self.hideableView.frame.size.height)
                }
            }
            for subview in self.hideableView.subviews as! [UIView] {
                if subview !== self.signatureLabel {
                    subview.transform = CGAffineTransformMakeTranslation(0, height)
                }
            }
            bottomView.contentOffset.y = self.signatureLabel.bounds.height
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(bottomView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === bottomView {
            if bottomView.contentOffset.y < 0 {
                topView.frame.size.height = 200 + -bottomView.contentOffset.y
                topView.contentOffset.y = bottomView.contentOffset.y
            } else {
                topView.frame.size.height = 200
                let percentage = min(bottomView.contentOffset.y, hideableView.bounds.height) / hideableView.bounds.height
                topView.contentOffset.y = pow(percentage * pow(100, 2), 0.5) / 100 * 10
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView === bottomView {
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .BeginFromCurrentState,
                animations: {
                    if self.bottomView.contentOffset.y < self.signatureLabel.bounds.height / 2 {
                        self.bottomView.contentOffset.y = 0
                    } else if self.bottomView.contentOffset.y < (self.signatureLabel.frame.height + self.hideableView.bounds.height) / 2 {
                        self.bottomView.contentOffset.y = self.signatureLabel.bounds.height
                    } else {
                        self.bottomView.contentOffset.y = self.hideableView.bounds.height
                    }
                },
                completion: nil)
        }
    }
    
    func delayHidingAvatarButtonImage() {
        preventHidingAvatarButtonImage()
        tryHidingAvatarButtonImage()
    }
    
    func preventHidingAvatarButtonImage() {
        avatarButtonTimer?.invalidate()
        avatarButtonTimer = nil
    }
    
    func tryHidingAvatarButtonImage() {
        avatarButtonTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "doHidingAvatarButtonImage", userInfo: nil, repeats: false)
    }
    
    func doHidingAvatarButtonImage() {
        avatarButtonState = .Normal
        avatarButton.userInteractionEnabled = false
        UIView.animateWithDuration(0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .BeginFromCurrentState,
            animations: {
                self.avatarButton.imageView!.alpha = 0
            }, completion: {
                finished in
                self.avatarButton.setImage(nil, forState: .Normal)
                self.avatarButton.userInteractionEnabled = true
        })
    }
    
    func toggleAvatarButtonImage() {
        if user.followed != nil {
            switch avatarButtonState {
            case .Normal:
                if user.followed! {
                    avatarButton.setImage(UIImage(named: "User_Following"), forState: .Normal)
                    avatarButtonState = .Following
                } else {
                    avatarButton.setImage(UIImage(named: "User_Follow"), forState: .Normal)
                    avatarButtonState = .NotFollowing
                }
                avatarButton.userInteractionEnabled = false
                UIView.animateWithDuration(0.2,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: {
                        self.avatarButton.imageView!.alpha = 1
                    }, completion: {
                        finished in
                        self.avatarButton.userInteractionEnabled = true
                    })
                break
            case .NotFollowing, .Following:
                avatarActivityIndicatorView.startAnimating()
                avatarButton.userInteractionEnabled = false
                preventHidingAvatarButtonImage()
                user.toggleFollow(
                    success: {
                        self.tryHidingAvatarButtonImage()
                        self.avatarActivityIndicatorView.stopAnimating()
                        self.avatarButton.userInteractionEnabled = true
                        if self.user.followed! {
                            self.avatarButton.setImage(UIImage(named: "User_Following"), forState: .Normal)
                            self.avatarButtonState = .Following
                        } else {
                            self.avatarButton.setImage(UIImage(named: "User_Follow"), forState: .Normal)
                            self.avatarButtonState = .NotFollowing
                        }
                    },
                    failure: {
                        error in
                        self.tryHidingAvatarButtonImage()
                        self.avatarActivityIndicatorView.stopAnimating()
                        self.avatarButton.userInteractionEnabled = true
                    })
                break
            default:
                break
            }
        }
    }
    
    internal func pushTopicListViewController() {
        msr_navigationController!.pushViewController(UserTopicListViewController(user: user), animated: true)
    }
    
    internal func pushFollowerViewController() {
        msr_navigationController!.pushViewController(UserListViewController(ID: user.id, listType: .UserFollower), animated: true)
    }
    
    internal func pushFollowingViewController() {
        msr_navigationController!.pushViewController(UserListViewController(ID: user.id, listType: .UserFollowing), animated: true)
    }
    
    internal func pushQuestionViewController() {
        msr_navigationController!.pushViewController(UserAskedQuestionListViewController(user: user), animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
}
