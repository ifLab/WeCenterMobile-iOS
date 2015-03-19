//
//  QuestionPublishmentViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/18.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionPublishmentViewController: UIViewController, ZFTokenFieldDataSource, ZFTokenFieldDelegate {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagsField: ZFTokenField!
    
    var tags = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        scrollView.alwaysBounceVertical = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsField.delegate = self
        tagsField.dataSource = self
        tagsField.textField.textColor = UIColor.lightTextColor()
        tagsField.textField.attributedPlaceholder = NSAttributedString(string: "...", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        tagsField.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        tagsField.textField.textColor = UIColor.lightTextColor()
//        tagsField.textField.attributedPlaceholder = NSAttributedString(string: "...", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
    }
    
    // MARK: - ZFTokenFieldDataSource
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 33
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        return UInt(tags.count)
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        let tag = tags[Int(index)]
        let label = UILabel()
        label.text = tag
        label.sizeToFit()
        label.frame.size.height = lineHeightForTokenInField(tagsField)
        label.backgroundColor = UIColor.lightTextColor()
        return label
    }
    
    // MARK: - ZFTokenFieldDelegate
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 5
    }
    
    func tokenField(tokenField: ZFTokenField!, didRemoveTokenAtIndex index: UInt) {
        tags.removeAtIndex(Int(index))
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        tags.append(text)
        tagsField.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
