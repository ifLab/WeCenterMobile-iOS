//
//  ArticleViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import DTCoreText
import UIKit

@objc protocol ArticleViewControllerPresentable {
    // Seriously, I don't like this language.
    // See The Swift Programming Language book - Optional Protocol Requirements
    /* @TODO: optional */ var date: NSDate? { get }
    /* @TODO: optional */ var body: String? { get }
    var user: User? { get }
    var id: NSNumber { get }
    var title: String? { get }
    var agreementCount: NSNumber? { get set }
    var evaluationRawValue: NSNumber? { get }
    func fetchDataObjectForArticleViewController(success success: ((ArticleViewControllerPresentable) -> Void)?, failure: ((NSError) -> Void)?)
    func evaluate(value value: Evaluation, success: (() -> Void)?, failure: ((NSError) -> Void)?)
}

extension Answer: ArticleViewControllerPresentable {
    func fetchDataObjectForArticleViewController(success success: ((ArticleViewControllerPresentable) -> Void)?, failure: ((NSError) -> Void)?) {
        Answer.fetch(ID: id, success: { success?($0) }, failure: failure)
    }
    var evaluationRawValue: NSNumber? {
        return evaluation?.rawValue
    }
}

extension Article: ArticleViewControllerPresentable {
    func fetchDataObjectForArticleViewController(success success: ((ArticleViewControllerPresentable) -> Void)?, failure: ((NSError) -> Void)?) {
        Article.fetch(ID: id, success: { success?($0) }, failure: failure)
    }
    var evaluationRawValue: NSNumber? {
        return evaluation?.rawValue
    }
}

class ArticleViewController: UIViewController, UIScrollViewDelegate, ArticleHeaderViewDelegate, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {
    
    lazy var header: ArticleHeaderView = {
        [weak self] in
        let v = ArticleHeaderView()
        v.delegate = self
        v.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        return v
    }()
    
    lazy var footer: ArticleFooterView = {
        [weak self] in
        let v = NSBundle.mainBundle().loadNibNamed("ArticleFooterView", owner: nil, options: nil).first as! ArticleFooterView
        v.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        return v
    }()
    
    lazy var bodyView: DTAttributedTextView = {
        [weak self] in
        let v = DTAttributedTextView()
        v.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        v.alwaysBounceVertical = true
        v.delaysContentTouches = false
        v.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        v.contentInset.top = self!.header.minHeight
        v.attributedTextContentView.edgeInsets = UIEdgeInsets(top: self!.header.maxHeight - self!.header.minHeight + 10, left: 10, bottom: self!.footer.bounds.height + 10, right: 10)
        v.contentOffset.y = -v.attributedTextContentView.edgeInsets.top - 10
        v.scrollIndicatorInsets.bottom = self!.footer.bounds.height
        v.backgroundColor = UIColor.clearColor()
        v.attributedTextContentView.delegate = self
        v.attributedTextContentView.shouldDrawImages = true
        v.attributedTextContentView.shouldDrawLinks = true
        v.attributedTextContentView.backgroundColor = UIColor.clearColor()
        return v
    }()
    
    var dataObject: ArticleViewControllerPresentable
    
    init(dataObject: ArticleViewControllerPresentable) {
        self.dataObject = dataObject
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let theme = SettingsManager.defaultManager.currentTheme
        view.addSubview(bodyView)
        view.addSubview(footer)
        bodyView.addSubview(header)
        bodyView.bringSubviewToFront(header)
        bodyView.indicatorStyle = theme.scrollViewIndicatorStyle
        bodyView.frame = view.bounds
        bodyView.delegate = self
        bodyView.msr_uiRefreshControl = UIRefreshControl()
        bodyView.msr_uiRefreshControl!.tintColor = theme.footnoteTextColor
        bodyView.msr_uiRefreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        bodyView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        bodyView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        view.backgroundColor = theme.backgroundColorA
        header.frame = CGRect(x: 0, y: -bodyView.contentInset.top, width: bodyView.bounds.width, height: header.maxHeight)
        header.userButtonA.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        header.userButtonB.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        header.backButton.addTarget(self, action: "didPressBackButton", forControlEvents: .TouchUpInside)
        footer.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
        footer.shareItem.target = self
        footer.shareItem.action = "didPressShareButton"
        footer.agreeItem.target = self
        footer.agreeItem.action = "didPressAgreeButton"
        footer.disagreeItem.target = self
        footer.disagreeItem.action = "didPressDisagreeButton"
        footer.commentItem.target = self
        footer.commentItem.action = "didPressCommentButton"
        msr_navigationBar!.hidden = true
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "attributedTextContentViewDidFinishLayout:", name: DTAttributedTextContentViewDidFinishLayoutNotification, object: bodyView.attributedTextContentView)
        reloadData()
        bodyView.msr_uiRefreshControl!.beginRefreshing()
        refresh()
    }
    
    func refresh() {
        dataObject.fetchDataObjectForArticleViewController(
            success: {
                [weak self] dataObject in
                self?.dataObject = dataObject
                self?.reloadData()
                self?.bodyView.msr_uiRefreshControl!.endRefreshing()
            }, failure: {
                [weak self] error in
                self?.bodyView.msr_uiRefreshControl!.endRefreshing()
                return
            })
    }
    
    func reloadData() {
        let theme = SettingsManager.defaultManager.currentTheme
        let options = [
            DTDefaultFontName: UIFont.systemFontOfSize(0).fontName,
            DTDefaultFontSize: 16,
            DTDefaultTextColor: theme.bodyTextColor,
            DTDefaultLineHeightMultiplier: 1.5,
            DTDefaultLinkColor: UIColor.msr_materialLightBlue(),
            DTDefaultLinkDecoration: true]
        header.update(dataObject: dataObject)
        footer.update(dataObject: dataObject)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let html = dataObject.date == nil || dataObject.body == nil ? dataObject.body ?? "加载中……" : dataObject.body! + "<br><p align=\"right\">\(dateFormatter.stringFromDate(dataObject.date!))</p>"
        bodyView.attributedString = NSAttributedString(
            HTMLData: html.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
            options: options,
            documentAttributes: nil)
        bodyView.relayoutText()
    }
    
    var bodyViewOffsetFirstLessThanHeaderNormalHeight = true
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === bodyView {
            header.frame.origin.y = bodyView.contentOffset.y
            let offset = bodyView.contentOffset.y + header.minHeight
            let velocity = bodyView.panGestureRecognizer.velocityInView(view).y
            let threshold: CGFloat = 200
            if offset <= header.maxHeight - header.normalHeight {
                header.frame.size.height = floor(header.maxHeight - offset) // The appearences of blur effect view will not correct unless it's height is an integer.
                bodyView.scrollIndicatorInsets.top = header.bounds.height
                bodyViewOffsetFirstLessThanHeaderNormalHeight = true
            } else {
                if bodyViewOffsetFirstLessThanHeaderNormalHeight {
                    bodyViewOffsetFirstLessThanHeaderNormalHeight = false
                    header.frame.size.height = header.normalHeight
                    bodyView.scrollIndicatorInsets.top = header.bounds.height
                }
            }
            animate() {
                [weak self] in
                if velocity < -threshold && !scrollView.msr_reachedBottom {
                    self?.footer.transform = CGAffineTransformMakeTranslation(0, self!.footer.bounds.height)
                }
                if velocity > threshold || scrollView.msr_reachedBottom {
                    self?.footer.transform = CGAffineTransformIdentity
                }
                return
            }
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === bodyView {
            let offset = targetContentOffset.memory.y + header.minHeight
            if offset > 0 && offset <= header.maxHeight - header.normalHeight {
                targetContentOffset.memory = CGPoint(x: 0, y: header.maxHeight - header.minHeight - header.normalHeight)
            }
        }
    }
    
    func articleHeaderViewMaxHeightDidChange(header: ArticleHeaderView) {
        if header === self.header {
            header.frame.origin.y = bodyView.contentOffset.y
            bodyView.attributedTextContentView.edgeInsets.top = header.maxHeight + 10
            let offset = bodyView.contentOffset.y + header.minHeight
            if offset <= header.maxHeight - header.normalHeight {
                animate() {
                    [weak self] in
                    self?.scrollViewDidScroll(self!.bodyView)
                    return
                }
            }
        }
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
        let attachments = bodyView.attributedTextContentView.layoutFrame.textAttachmentsWithPredicate(predicate) as? [DTImageTextAttachment] ?? []
        for attachment in attachments {
            attachment.originalSize = size
            let v = bodyView.attributedTextContentView
            let maxWidth = v.bounds.width - v.edgeInsets.left - v.edgeInsets.right
            if size.width > maxWidth {
                let scale = maxWidth / size.width
                attachment.displaySize = CGSize(width: size.width * scale, height: size.height * scale)
            }
        }
        bodyView.attributedTextContentView.layouter = nil
        bodyView.relayoutText()
    }
    
    func handleLongPressGesture(recoginizer: UILongPressGestureRecognizer) {
        if recoginizer.state == .Began {
            didLongPressLinkButton(recoginizer.view as! DTLinkButton)
        }
    }
    
    func didPressCommentButton() {
        if let dataObject = dataObject as? CommentListViewControllerPresentable {
            msr_navigationController!.pushViewController(CommentListViewController(dataObject: dataObject), animated: true)
        }
    }
    
    func didLongPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func didPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserViewController(user: user), animated: true)
        }
    }
    
    func didPressBackButton() {
        msr_navigationController!.popViewController(animated: true)
    }
    
    func didPressShareButton() {
        let title = dataObject.title!
        let image = dataObject.user?.avatar ?? defaultUserAvatar
        let body = dataObject.body!.wc_plainString
        let url: String = (dataObject is Answer) ? "\(NetworkManager.defaultManager!.website)?/question/\((dataObject as! Answer).question!.id)" : "\(NetworkManager.defaultManager!.website)?/article/\(dataObject.id)"
        var items = [title, body, NSURL(string: url)!]
        if image != nil {
            items.append(image!)
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: [SinaWeiboActivity(), WeChatSessionActivity(), WeChatTimelineActivity()])
        showDetailViewController(vc, sender: self)
    }
    
    func didPressAgreeButton() {
        if let rawValue = dataObject.evaluationRawValue?.integerValue {
            let e = Evaluation(rawValue: rawValue)!
            evaluate(value: e == .Up ? .None : .Up)
        }
    }
    
    func didPressDisagreeButton() {
        if let rawValue = dataObject.evaluationRawValue?.integerValue {
            let e = Evaluation(rawValue: rawValue)!
            evaluate(value: e == .Down ? .None : .Down)
        }
    }
    
    func evaluate(value value: Evaluation) {
        let count = dataObject.agreementCount?.integerValue
        dataObject.agreementCount = nil
        footer.update(dataObject: dataObject)
        dataObject.agreementCount = count
        dataObject.evaluate(
            value: value,
            success: {
                [weak self] in
                self?.footer.update(dataObject: self!.dataObject)
                return
            },
            failure: {
                [weak self] error in
                self?.footer.update(dataObject: self!.dataObject)
                let message = error.userInfo[NSLocalizedDescriptionKey] as? String ?? "未知错误"
                let ac = UIAlertController(title: "错误", message: message, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self?.showDetailViewController(ac, sender: self)
                return
            })
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
    
    func attributedTextContentViewDidFinishLayout(notification: NSNotification) {
        bodyView.contentSize.height = max(bodyView.attributedTextContentView.bounds.height, bodyView.bounds.height + header.maxHeight - header.normalHeight - header.minHeight)
    }
    
    func animate(animations: (() -> Void)) {
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.7,
            options: .BeginFromCurrentState,
            animations: animations,
            completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
