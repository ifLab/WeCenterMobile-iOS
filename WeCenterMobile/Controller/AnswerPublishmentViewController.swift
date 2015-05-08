//
//  AnswerPublishmentViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/23.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import AFNetworking
import AssetsLibrary
import EAColourfulProgressView
import SVProgressHUD
import UIKit
import UzysAssetsPickerController
import ZFTokenField

@objc protocol AnswerPublishmentViewControllerDelegate {
    optional func answerPublishmentViewController(answerPublishmentViewController: AnswerPublishmentViewController, didPublishAnswer answer: Answer)
}

class AnswerPublishmentViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UzysAssetsPickerControllerDelegate {
    
    var question: Question!
    var delegate: AnswerPublishmentViewControllerDelegate?
    
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var bodyField: UITextView!
    
    typealias SelfType = AnswerPublishmentViewController
    
    static let identifiers = ["ImageCell", "ButtonCell"]
    static let imageViewTag = 23333
    static let progressViewTag = 23334
    static let buttonTag = 23335
    static let overlayViewTag = 23336
    static let notAnAttachID = -1
    
    var converting = false
    var images = [UIImage]()
    var attachIDs = [Int]()
    var operations = [AFHTTPRequestOperation]()
    var uploadingProgresses = [Int]()
    var uploaded = [Bool]() {
        didSet {
            if uploaded.reduce(true, combine: { $0 && $1 }) {
                allUploaded.signal()
            }
        }
    }
    var allUploaded = NSCondition()
    let maxProgress = 100
    var imageAdditonButton = UIButton()
    
    var attachKey = "\(NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970)".msr_MD5EncryptedString
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        publishButton.addTarget(self, action: "publish", forControlEvents: .TouchUpInside)
        dismissButton.msr_setBackgroundImageWithColor(dismissButton.backgroundColor!)
        publishButton.msr_setBackgroundImageWithColor(publishButton.backgroundColor!)
        dismissButton.backgroundColor = UIColor.clearColor()
        publishButton.backgroundColor = UIColor.clearColor()
        scrollView.alwaysBounceVertical = true
        scrollView.indicatorStyle = .White
        for identifier in SelfType.identifiers {
            imageCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        }
        imageCollectionView.backgroundColor = UIColor.clearColor()
        imageAdditonButton.setImage(UIImage(named: "AddButton"), forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.reloadData()
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
        if indexPath.item < images.count {
            let image = images[indexPath.item]
            let maxProgress = self.maxProgress
            let uploadingProgress = Int(uploadingProgresses[indexPath.item])
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(SelfType.identifiers[0], forIndexPath: indexPath) as! UICollectionViewCell
            var imageView: UIImageView! = cell.contentView.viewWithTag(SelfType.imageViewTag) as? UIImageView
            if imageView == nil {
                imageView = UIImageView()
                imageView.tag = SelfType.imageViewTag
                cell.contentView.addSubview(imageView)
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                imageView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                imageView.msr_addAllEdgeAttachedConstraintsToSuperview()
            }
            imageView!.image = images[indexPath.item]
            var overlayView: UIView! = cell.contentView.viewWithTag(SelfType.overlayViewTag)
            if overlayView == nil {
                overlayView = UIView()
                overlayView.tag = SelfType.overlayViewTag
                cell.contentView.insertSubview(overlayView, aboveSubview: imageView)
                overlayView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                overlayView.msr_addAllEdgeAttachedConstraintsToSuperview()
                overlayView.backgroundColor = scrollView.backgroundColor!.colorWithAlphaComponent(0.7)
            }
            var progressView: EAColourfulProgressView! = cell.contentView.viewWithTag(SelfType.progressViewTag) as? EAColourfulProgressView
            if progressView == nil {
                progressView = NSBundle.mainBundle().loadNibNamed("ImageUploadingProgressBar", owner: self, options: nil).first as! EAColourfulProgressView
                progressView.tag = SelfType.progressViewTag
                progressView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                progressView.msr_addHeightConstraintWithValue(8)
                cell.contentView.insertSubview(progressView, aboveSubview: overlayView)
                progressView.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
                progressView.msr_addBottomAttachedConstraintToSuperview()
                progressView.maximumValue = UInt(maxProgress)
            }
            overlayView.alpha = uploadingProgress == maxProgress ? 0 : 1
            progressView.alpha = uploadingProgress == maxProgress ? 0 : 1
            progressView.updateToCurrentValue(maxProgress - uploadingProgress, animated: false)
        } else {
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(SelfType.identifiers[1], forIndexPath: indexPath) as! UICollectionViewCell
            var button: UIButton! = cell.contentView.viewWithTag(SelfType.buttonTag) as? UIButton
            if button == nil {
                button = UIButton()
                button.tag = SelfType.buttonTag
                cell.contentView.addSubview(button)
                button.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                button.msr_addAllEdgeAttachedConstraintsToSuperview()
                button.setImage(UIImage(named: "MSRAddButton")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                button.imageView!.tintColor = UIColor.msr_materialBlueGray800()
                button.addTarget(self, action: "showPickerController", forControlEvents: .TouchUpInside)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.item < images.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let image = images[indexPath.item]
        let ac = UIAlertController(title: "再次确认", message: "您确定要删除这张图片吗？", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "删除图片", style: .Destructive)
            /* handler: */ {
                [weak self] action in
                if let self_ = self {
                    if let index = find(self_.images, image) {
                        self_.removeDataAtIndex(index)
                        self_.imageCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
                    }
                }
                return
            })
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - UzysAssetsPickerControllerDelegate
    
    func uzysAssetsPickerController(picker: UzysAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        SVProgressHUD.showWithMaskType(.Gradient)
        converting = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            [weak self] in
            if let self_ = self {
                let rs = map(assets, { ($0 as! ALAsset).defaultRepresentation() })
                var images = [UIImage]()
                var uploadingProgress = [Int]()
                var uploaded = [Bool]()
                var attachIDs = [Int]()
                for r in rs {
                    let image = UIImage(
                        CGImage: r.fullResolutionImage().takeUnretainedValue(),
                        scale: CGFloat(r.scale()),
                        orientation: UIImageOrientation(rawValue: r.orientation().rawValue)!)!
                    images.append(image)
                    uploadingProgress.append(0)
                    uploaded.append(false)
                    attachIDs.append(SelfType.notAnAttachID)
                }
                let jpegs = map(images) {
                    return UIImageJPEGRepresentation($0, 0.5)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self_.images.extend(images)
                    self_.uploadingProgresses.extend(uploadingProgress)
                    self_.allUploaded.lock()
                    self_.uploaded.extend(uploaded)
                    self_.allUploaded.unlock()
                    self_.attachIDs.extend(attachIDs)
                    for i in 0..<images.count {
                        let image = images[i]
                        let jpeg = jpegs[i]
                        let operation = NetworkManager.defaultManager!.request("Upload Attachment",
                            GETParameters: [
                                "id": "answer",
                                "attach_access_key": self_.attachKey],
                            POSTParameters: nil,
                            constructingBodyWithBlock: {
                                data in
                                data?.appendPartWithFileData(jpeg, name: "qqfile", fileName: "image.jpg", mimeType: "image/png")
                                return
                            },
                            success: {
                                data in
                                if let index = find(self_.images, image) {
                                    self_.attachIDs[index] = Int(msr_object: data["attach_id"])!
                                    self_.allUploaded.lock()
                                    self_.uploaded[index] = true
                                    self_.allUploaded.unlock()
                                    self_.uploadingProgresses[index] = self_.maxProgress
                                    self_.imageCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
                                }
                                return
                            },
                            failure: {
                                error in
                                var message = error.userInfo?[NSLocalizedDescriptionKey] as? String
                                if message == nil && error.code != NSURLErrorCancelled {
                                    message = "未知错误。"
                                }
                                if message != nil {
                                    let ac = UIAlertController(title: "上传失败", message: message!, preferredStyle: .Alert) // Needs localization
                                    ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                                    self_.presentViewController(ac, animated: true, completion: nil)
                                }
                                if let index = find(self_.images, image) {
                                    self_.removeDataAtIndex(index)
                                    self_.imageCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
                                }
                                return
                        })!
                        operation.setUploadProgressBlock() {
                            bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            if let index = find(self_.images, image) {
                                if totalBytesWritten == totalBytesExpectedToWrite {
                                    self_.allUploaded.lock()
                                    self_.uploaded[index] = true
                                    self_.allUploaded.unlock()
                                }
                                self_.uploadingProgresses[index] = Int(totalBytesWritten * Int64(self_.maxProgress) / totalBytesExpectedToWrite)
                                self_.imageCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
                            }
                            return
                        }
                        self_.operations.append(operation)
                    }
                    self_.imageCollectionView.reloadData()
                    self_.converting = false
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection(picker: UzysAssetsPickerController!) {
        let ac = UIAlertController(title: "已达到上限", message: "您一次最多勾选\(picker.maximumNumberOfSelectionPhoto)张图片。", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil)) // Needs localization
        picker.presentViewController(ac, animated: true, completion: nil)
    }
    
    func showPickerController() {
        let c = UzysAppearanceConfig()
        c.cameraImageName = "Camera-Line"
        c.closeImageName = "X"
        c.finishSelectionButtonColor = UIColor.msr_materialBlueGray()
        UzysAssetsPickerController.setUpAppearanceConfig(c)
        let pc = MediaPickerController()
        pc.delegate = self
        pc.maximumNumberOfSelectionPhoto = 5
        pc.maximumNumberOfSelectionVideo = 0
        presentViewController(pc, animated: true, completion: nil)
    }
    
    func removeDataAtIndex(index: Int) {
        images.removeAtIndex(index)
        attachIDs.removeAtIndex(index)
        uploadingProgresses.removeAtIndex(index)
        operations[index].cancel()
        operations.removeAtIndex(index)
        allUploaded.lock()
        uploaded.removeAtIndex(index)
        allUploaded.unlock()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func dismiss() {
        if converting {
            return
        }
        let ac = UIAlertController(title: "再次确认", message: "您确定要丢弃已输入的信息吗？这些信息将不会保存。", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "丢弃信息", style: .Destructive)
            /* handler: */ {
                [weak self] action in
                if let self_ = self {
                    self_.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func publish() {
        if converting {
            return
        }
        let ac = UIAlertController(title: "再次确认", message: "您确定要发布吗？", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "是的", style: .Default)
            /* handler: */ {
                [weak self] action in
                if let self_ = self {
                    SVProgressHUD.showWithMaskType(.Gradient)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self_.allUploaded.lock()
                        let count = self_.uploaded.count
                        if !self_.uploaded.reduce(true, combine: { $0 && $1 }) {
                            self_.allUploaded.wait()
                        }
                        if count != self_.uploaded.count {
                            self_.allUploaded.unlock()
                            dispatch_async(dispatch_get_main_queue()) {
                                SVProgressHUD.dismiss()
                            }
                            return
                        } else {
                            self_.allUploaded.unlock()
                            dispatch_async(dispatch_get_main_queue()) {
                                let manager = DataManager.temporaryManager!
                                let answer = Answer.temporaryObject()
                                let question = Question.temporaryObject()
                                question.id = self_.question.id
                                answer.question = question
                                answer.body = self_.bodyField.text ?? ""
                                var body = self_.bodyField.text ?? ""
                                for id in self_.attachIDs {
                                    body += "\n[attach]\(id)[/attach]"
                                }
                                answer.body = body
                                answer.post(
                                    attachKey: self_.attachKey,
                                    success: {
                                        answer in
                                        SVProgressHUD.dismiss()
                                        SVProgressHUD.showSuccessWithStatus("已发布", maskType: .Gradient)
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                                            SVProgressHUD.dismiss()
                                            self_.dismissViewControllerAnimated(true, completion: nil)
                                            self_.delegate?.answerPublishmentViewController?(self_, didPublishAnswer: answer)
                                        }
                                    },
                                    failure: {
                                        error in
                                        SVProgressHUD.dismiss()
                                        let ac = UIAlertController(title: "发布失败", message: error.userInfo?[NSLocalizedDescriptionKey] as? String ?? "未知错误。", preferredStyle: .Alert)
                                        ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                                        self_.presentViewController(ac, animated: true, completion: nil)
                                })
                            }
                        }
                    }
                }
            })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
}
