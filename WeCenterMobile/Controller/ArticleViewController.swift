//
//  ArticleViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import DTCoreText
import UIKit

class ArticleViewController: UIViewController, UIScrollViewDelegate, ArticleHeaderViewDelegate, DTAttributedTextContentViewDelegate {
    
    lazy var header: ArticleHeaderView = {
        [weak self] in
        let v = ArticleHeaderView()
        v.delegate = self
        v.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        return v
    }()
    
    lazy var footer: ArticleFooterView = {
        [weak self] in
        let v = NSBundle.mainBundle().loadNibNamed("ArticleFooterView", owner: nil, options: nil).first as! ArticleFooterView
        v.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        return v
    }()
    
    lazy var bodyView: DTAttributedTextView = {
        [weak self] in
        let v = DTAttributedTextView()
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        v.alwaysBounceVertical = true
        v.contentInset.top = self!.header.minHeight
        v.attributedTextContentView.edgeInsets = UIEdgeInsets(top: self!.header.maxHeight - self!.header.minHeight + 10, left: 10, bottom: self!.footer.bounds.height + 10, right: 10)
        v.contentOffset.y = -v.attributedTextContentView.edgeInsets.top - 10
        v.indicatorStyle = .White
        v.scrollIndicatorInsets.bottom = self!.footer.bounds.height
        v.backgroundColor = UIColor.clearColor()
        v.attributedTextContentView.delegate = self
        v.attributedTextContentView.shouldDrawImages = true
        v.attributedTextContentView.shouldDrawLinks = true
        v.attributedTextContentView.backgroundColor = UIColor.clearColor()
        return v
    }()
    
    var article: Article
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(bodyView)
        view.addSubview(footer)
        bodyView.addSubview(header)
        bodyView.sendSubviewToBack(bodyView.attributedTextContentView)
        bodyView.frame = view.bounds
        bodyView.delegate = self
        bodyView.msr_uiRefreshControl = UIRefreshControl()
        bodyView.msr_uiRefreshControl!.tintColor = UIColor.whiteColor()
        bodyView.msr_uiRefreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        view.backgroundColor = UIColor.msr_materialBlueGray800()
        header.frame = CGRect(x: 0, y: -bodyView.contentInset.top, width: bodyView.bounds.width, height: header.maxHeight)
        footer.frame = CGRect(x: 0, y: view.bounds.height - 50, width: view.bounds.width, height: 50)
        msr_navigationBar!.hidden = true
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyView.msr_uiRefreshControl!.beginRefreshing()
        refresh()
    }
    
    func refresh() {
        Article.fetch(
            ID: article.id,
            success: {
                [weak self] article in
                self?.article = article
                self?.reloadData()
                self?.bodyView.msr_uiRefreshControl!.endRefreshing()
                return
            },
            failure: {
                [weak self] error in
                self?.bodyView.msr_uiRefreshControl!.endRefreshing()
                return
            })
    }
    
    func reloadData() {
        header.update(article: article)
        footer.update(article: article)
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
        var html = article.date == nil ? article.body ?? "加载中……" : article.body! + "<br><p align=\"right\">\(dateFormatter.stringFromDate(article.date!))</p>"
        bodyView.attributedString = NSAttributedString(
            HTMLData: html.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
            options: options,
            documentAttributes: nil)
        bodyView.relayoutText()
    }
    
    var bodyViewOffsetFirstLessThanHeaderNormalHeight: Bool = true
    
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
                if bodyView.panGestureRecognizer.state == .Changed {
                    animate() {
                        [weak self] in
                        if velocity < -threshold {
                            self?.header.frame.size.height = self!.header.minHeight
                        }
                        if velocity > threshold {
                            self?.header.frame.size.height = self!.header.normalHeight
                        }
                        return
                    }
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
        return .LightContent
    }

    
}
