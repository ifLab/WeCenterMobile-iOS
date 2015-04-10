//
//  UserViewController.swift
//  WeCenterMobile
//
//  Created by EricLee on 14-7-20.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UIScrollViewDelegate {
    
    lazy var header: UserViewControllerHeaderView = {
        let v =  NSBundle.mainBundle().loadNibNamed("UserViewControllerHeaderView", owner: nil, options: nil).first as! UserViewControllerHeaderView
        v.msr_addHeightConstraintWithValue(v.maxHeight)
        return v
    }()
    lazy var bodyView: UIScrollView = {
        [weak self] in
        let v = UIScrollView()
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        v.alwaysBounceVertical = true
        v.contentInset.top = self?.header.maxHeight ?? 0
        v.scrollIndicatorInsets.top = self?.header.minHeight ?? 0
        v.contentOffset.y = -v.contentInset.top
        v.delegate = self
        return v
    }()
    let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(bodyView)
        view.addSubview(header)
        view.backgroundColor = UIColor.msr_materialBrown900()
        bodyView.msr_addAllEdgeAttachedConstraintsToSuperview()
        header.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        header.msr_addTopAttachedConstraintToSuperview()
        msr_navigationBar!.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        bodyView.contentSize = CGSize(width: 1, height: 1000)
        user.fetchProfile(
            success: {
                [weak self] in
                self?.reloadData()
                return
            },
            failure: {
                error in
                NSLog("%@", error)
                return
            })
    }
    
    func reloadData() {
        header.update(user)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === bodyView {
            let offset = bodyView.contentOffset.y + bodyView.contentInset.top
            header.msr_heightConstraint!.constant = max(header.maxHeight - offset, header.minHeight)
            header.layoutIfNeeded()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
