//
//  AnswerViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerViewController: UIViewController, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {
    
    lazy var topBar: AnswerTopBar = {
        [weak self] in
        let v = NSBundle.mainBundle().loadNibNamed("AnswerTopBar", owner: self, options: nil).first as! AnswerTopBar
        v.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        return v
    }()
    
    lazy var bottomBar: AnswerBottomBar = {
        [weak self] in
        let b = NSBundle.mainBundle().loadNibNamed("AnswerBottomBar", owner: self, options: nil).first as! AnswerBottomBar
        b.shareButton.addTarget(self, action: "share", forControlEvents: .TouchUpInside)
        b.commentButton.addTarget(self, action: "pushCommentListViewController", forControlEvents: .TouchUpInside)
        return b
    }()
    
    lazy var answerBodyView: DTAttributedTextView = {
        [weak self] in
        let v = DTAttributedTextView()
        v.alwaysBounceVertical = true
        v.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        v.attributedTextContentView.backgroundColor = UIColor.clearColor()
        v.attributedTextContentView.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        v.attributedTextContentView.delegate = self
        v.attributedTextContentView.shouldDrawImages = true
        v.attributedTextContentView.shouldDrawLinks = true
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        NSNotificationCenter.defaultCenter().addObserverForName(DTAttributedTextContentViewDidFinishLayoutNotification, object: v.attributedTextContentView, queue: NSOperationQueue.mainQueue()) {
            notification in
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }
        return v
    }()
    
    var answer: Answer
    
    init(answer: Answer) {
        self.answer = answer
        super.init(nibName: nil, bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "回答"
        view.addSubview(answerBodyView)
        view.addSubview(topBar)
        view.addSubview(bottomBar)
        view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bottomBar, attribute: .Bottom, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0))
        answerBodyView.frame = view.bounds
        answerBodyView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        answerBodyView.indicatorStyle = .White
        view.backgroundColor = UIColor.msr_materialBlueGray800()
        msr_navigationBar!.barStyle = .Black
        msr_navigationBar!.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        Answer.fetch(
            ID: answer.id,
            success: {
                [weak self] answer in
                self?.reloadData()
                return
            },
            failure: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let inset = UIEdgeInsets(top: topBar.frame.msr_bottom, left: 0, bottom: bottomBar.bounds.height, right: 0)
        answerBodyView.contentInset = inset
        answerBodyView.scrollIndicatorInsets = inset
    }
    
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment is DTImageTextAttachment {
            let imageView = DTLazyImageView(frame: frame)
            imageView.delegate = self
            imageView.url = attachment.contentURL
            return imageView
        }
        return nil
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForLink url: NSURL!, identifier: String!, frame: CGRect) -> UIView! {
        let button = DTLinkButton()
        button.URL = url
        button.GUID = identifier
        button.frame = frame
        button.showsTouchWhenHighlighted = true
        button.minimumHitSize = CGSize(width: 44, height: 44)
        button.addTarget(self, action: "didPressLinkButton:", forControlEvents: .TouchUpInside)
        button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:"))
        return button
    }
    
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let predicate = NSPredicate(format: "contentURL == %@", lazyImageView.url)
        let attachments = answerBodyView.attributedTextContentView.layoutFrame.textAttachmentsWithPredicate(predicate) as? [DTImageTextAttachment] ?? []
        for attachment in attachments {
            attachment.originalSize = size
            let v = answerBodyView.attributedTextContentView
            let maxWidth = v.bounds.width - v.edgeInsets.left - v.edgeInsets.right
            if size.width > maxWidth {
                let scale = maxWidth / size.width
                attachment.displaySize = CGSize(width: size.width * scale, height: size.height * scale)
            }
        }
        answerBodyView.attributedTextContentView.layouter = nil
        answerBodyView.attributedTextContentView.relayoutText()
    }
    
    
    func reloadData() {
        topBar.update(answer: answer, updateImage: true)
        let options = [
            DTDefaultFontName: UIFont.systemFontOfSize(0).fontName,
            DTDefaultFontSize: 16,
            DTDefaultTextColor: UIColor.lightTextColor(),
            DTDefaultLineHeightMultiplier: 1.5,
            DTDefaultLinkColor: UIColor.msr_materialLightBlue800(),
            DTDefaultLinkDecoration: true]
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var html = answer.date == nil ? answer.body ?? "加载中……" : answer.body! + "<br><p align=\"right\">\(dateFormatter.stringFromDate(answer.date!))</p>"
        answerBodyView.attributedString = NSAttributedString(
            HTMLData: html.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
            options: options,
            documentAttributes: nil)
        answerBodyView.relayoutText()
    }
    
    func share() {
        let c = UIActivityViewController(activityItems: [], applicationActivities: nil)
        presentViewController(c, animated: true, completion: nil)
    }
    
//    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject // called to determine data type. only the class of the return type is consulted. it should match what -itemForActivityType: returns later
//    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? // called to fetch data after an activity is selected. you can return nil.
//    
//    optional func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String // if activity supports a Subject field. iOS 7.0
//    optional func activityViewController(activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: String?) -> String // UTI for item if it is an NSData. iOS 7.0. will be called with nil activity and then selected activity
//    optional func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String!, suggestedSize size: CGSize) -> UIImage! // if activity supports preview image. iOS 7.0
    
    func pushCommentListViewController() {
        msr_navigationController!.pushViewController(AnswerCommentListViewController(answer: answer), animated: true)
    }
    
    func handleLongPressGesture(recoginizer: UILongPressGestureRecognizer) {
        if recoginizer.state == .Began {
            didLongPressLinkButton(recoginizer.view as! DTLinkButton)
        }
    }
    
    
    func didLongPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func didPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func didPressUserButton(button: UIButton) {
        if let user = button.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    
    func presentLinkAlertControllerWithURL(URL: NSURL) {
        let ac = UIAlertController(title: "链接", message: URL.absoluteString, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "跳转到 Safari", style: .Default) {
            action in
            UIApplication.sharedApplication().openURL(URL)
        })
        ac.addAction(UIAlertAction(title: "复制到剪贴板", style: .Default) {
            [weak self] action in
            UIPasteboard.generalPasteboard().string = URL.absoluteString
            let ac = UIAlertController(title: "已复制", message: nil, preferredStyle: .Alert)
            self?.presentViewController(ac, animated: true) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                    ac.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
