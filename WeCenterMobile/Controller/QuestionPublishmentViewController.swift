//
//  QuestionPublishmentViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/18.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionPublishmentViewController: UIViewController, ZFTokenFieldDataSource, ZFTokenFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagsField: ZFTokenField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionViewHeightConstraint: NSLayoutConstraint!
    
    let identifier = "ImageCell"
    
    var tags = [String]()
    var images = [UIImage]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        scrollView.alwaysBounceVertical = true
        tagsField.textField.textColor = UIColor.lightTextColor()
        tagsField.textField.font = UIFont.systemFontOfSize(14)
        tagsField.textField.attributedPlaceholder = NSAttributedString(string: "...", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        imageCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsField.reloadData()
        imageCollectionView.reloadData()
    }
    
    // MARK: - ZFTokenFieldDataSource
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 24
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        return UInt(tags.count)
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        let tag = tags[Int(index)]
        let label = UILabel()
        label.text = tag
        label.font = UIFont.systemFontOfSize(14)
        label.sizeToFit()
        label.frame.size.height = lineHeightForTokenInField(tagsField)
        label.frame.size.width += 20
        label.textAlignment = .Center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
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
    
    // MARK: - UICollectionDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        println(__FUNCTION__)
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println(__FUNCTION__)
        return 10 // images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        println(__FUNCTION__)
        NSLog("%@", indexPath)
        let cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.msr_randomColor(opaque: true)
        return cell
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageCollectionView.reloadData()
        imageCollectionViewHeightConstraint.constant = imageCollectionView.contentSize.height
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
