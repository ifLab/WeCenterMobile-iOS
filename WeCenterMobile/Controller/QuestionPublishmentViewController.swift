//
//  QuestionPublishmentViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/18.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionPublishmentViewController: UIViewController, ZFTokenFieldDataSource, ZFTokenFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UzysAssetsPickerControllerDelegate {
    
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagsField: ZFTokenField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let identifiers = ["ImageCell", "ButtonCell"]
    let imageViewTag = 23333
    let activityIndicatorViewTag = 23334
    let buttonTag = 23335
    
    var activityIndicatorViews = [UIActivityIndicatorView]()
    
    var tags = [String]()
    var images = [UIImage]()
    var imageAdditonButton = UIButton()
    
    var timeKey: NSTimeInterval = NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        previewButton.addTarget(self, action: "preview", forControlEvents: .TouchUpInside)
        scrollView.alwaysBounceVertical = true
        tagsField.textField.textColor = UIColor.lightTextColor()
        tagsField.textField.font = UIFont.systemFontOfSize(14)
        tagsField.textField.attributedPlaceholder = NSAttributedString(string: "...", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        tagsField.textField.keyboardAppearance = .Dark
        for identifier in identifiers {
            imageCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        }
        imageCollectionView.backgroundColor = UIColor.clearColor()
        imageAdditonButton.setImage(UIImage(named: "AddButton"), forState: .Normal)
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
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell!
        if indexPath.row < images.count {
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(identifiers[0], forIndexPath: indexPath) as! UICollectionViewCell
            var imageView = cell.contentView.viewWithTag(imageViewTag) as? UIImageView
            if imageView == nil {
                imageView = UIImageView()
                imageView!.tag = imageViewTag
                cell.contentView.addSubview(imageView!)
                imageView!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                imageView!.msr_addAllEdgeAttachedConstraintsToSuperview()
            }
            var activityIndicatorView = cell.contentView.viewWithTag(activityIndicatorViewTag) as? UIActivityIndicatorView
            if activityIndicatorView == nil {
                activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
                activityIndicatorView!.tag = activityIndicatorViewTag
                cell.contentView.insertSubview(activityIndicatorView!, aboveSubview: imageView!)
                activityIndicatorView!.backgroundColor = UIColor.msr_materialBlueGray800().colorWithAlphaComponent(0.7)
                activityIndicatorView!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                activityIndicatorView!.msr_addAllEdgeAttachedConstraintsToSuperview()
            }
            imageView!.image = images[indexPath.row]
            cell.backgroundColor = UIColor.msr_randomColor(opaque: true)
        } else {
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(identifiers[1], forIndexPath: indexPath) as! UICollectionViewCell
            var button = cell.contentView.viewWithTag(buttonTag) as? UIButton
            if button == nil {
                button = UIButton()
                button!.tag = buttonTag
                cell.contentView.addSubview(button!)
                button!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                button!.msr_addAllEdgeAttachedConstraintsToSuperview()
                button!.setImage(UIImage(named: "MSRAddButton")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                button!.imageView!.tintColor = UIColor.msr_materialBlueGray800()
                button!.addTarget(self, action: "showPickerController", forControlEvents: .TouchUpInside)
            }
        }
        return cell
    }
    
    // MARK: - UzysAssetsPickerControllerDelegate
    
    func uzysAssetsPickerController(picker: UzysAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        let rs = map(assets, { ($0 as! ALAsset).defaultRepresentation() })
        var begin = images.count
        for r in rs {
            let image = UIImage(
                CGImage: r.fullResolutionImage().takeRetainedValue(),
                scale: CGFloat(r.scale()),
                orientation: UIImageOrientation(rawValue: r.orientation().rawValue)!)!
            images.append(image)
        }
        var end = images.count
        imageCollectionView.reloadData()
        for i in begin..<end {
//            let cell = imageCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
//            let activityIndicatorView = cell!.contentView.viewWithTag(activityIndicatorViewTag) as! UIActivityIndicatorView
//            activityIndicatorView.startAnimating()
            println(images[i])
            NetworkManager.defaultManager!.request("Upload Attach",
                GETParameters: [
                    "id": "question",
                    "attach_access_key": "\(timeKey)".msr_MD5EncryptedString],
                POSTParameters: [
                    "qqfile": images[i]],
                success: {
                    data in
                    println(data)
                    return
                },
                failure: {
                    error in
                    println(error)
                    return
                })
        }
    }
    
    func uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection(picker: UzysAssetsPickerController!) {
        
    }
    
    func showPickerController() {
        let pc = MediaPickerController()
        let c = UzysAppearanceConfig.sharedConfig()
        c.cameraImageName = "Camera-Line"
        c.closeImageName = "X"
        c.finishSelectionButtonColor = UIColor.msr_materialBlueGray()
//        @property (nonatomic, strong) NSString *assetSelectedImageName;
//        //deselected photo/video checkmark
//        @property (nonatomic, strong) NSString *assetDeselectedImageName;
//        @property (nonatomic, strong) NSString *assetsGroupSelectedImageName;
//        @property (nonatomic, strong) NSString *cameraImageName;
//        @property (nonatomic, strong) NSString *closeImageName;
//        @property (nonatomic, strong) UIColor *finishSelectionButtonColor;
//        UzysAppearanceConfig *appearanceConfig = [[UzysAppearanceConfig alloc] init];
//        appearanceConfig.finishSelectionButtonColor = [UIColor blueColor];
//        appearanceConfig.assetsGroupSelectedImageName = @"checker.png";
//        [UzysAssetsPickerController setUpAppearanceConfig:appearanceConfig];
        pc.delegate = self
        pc.maximumNumberOfSelectionPhoto = 1
        pc.maximumNumberOfSelectionVideo = 0
        presentViewController(pc, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func preview() {
    }
    
}
