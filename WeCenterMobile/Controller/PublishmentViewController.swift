//
//  PublishmentViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/18.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import AFNetworking
import AssetsLibrary
import EAColourfulProgressView
import SVProgressHUD
import UIKit
import ZFTokenField

@objc protocol PublishmentViewControllerPresentable {
    var topics: Set<Topic> { get set }
    var title: String? { get set }
    var body: String? { get set }
    var attachmentKey: String? { get set }
    func post(success success: (() -> Void)?, failure: ((NSError) -> Void)?)
    func uploadImageWithJPEGData(jpegData: NSData, success: ((Int) -> Void)?, failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation
}

extension Question: PublishmentViewControllerPresentable {}
extension Answer: PublishmentViewControllerPresentable {
    var topics: Set<Topic> {
        set {
            question?.topics = newValue
        }
        get {
            return question?.topics ?? Set()
        }
    }
}
extension Article: PublishmentViewControllerPresentable {}

@objc protocol PublishmentViewControllerDelegate: class {
    optional func publishmentViewControllerDidSuccessfullyPublishDataObject(publishmentViewController: PublishmentViewController)
}

class PublishmentViewController: UIViewController, ZFTokenFieldDataSource, ZFTokenFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagsField: ZFTokenField?
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var titleField: MSRTextView?
    @IBOutlet weak var bodyField: MSRTextView!
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var tagsLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imagesLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    typealias SelfType = PublishmentViewController
    
    var delegate: PublishmentViewControllerDelegate?
    
    var dataObject: PublishmentViewControllerPresentable! {
        didSet {
            if dataObject.attachmentKey == nil {
                dataObject.attachmentKey = "\(NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970)".msr_MD5EncryptedString
            }
        }
    }
    
    static let identifiers = ["ImageCell", "ButtonCell"]
    static let imageViewTag = 23333
    static let progressViewTag = 23334
    static let buttonTag = 23335
    static let overlayViewTag = 23336
    static let notAnAttachID = -1
    static let maxImageSideLength: CGFloat = 1920
    static let imageCompressionQuality: CGFloat = 0.7
    
    var converting = false
    var tags = [String]()
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        for v in [UIView?](arrayLiteral: titleField, tagsField, bodyField) {
            v?.msr_borderColor = theme.borderColorA
            v?.backgroundColor = theme.backgroundColorB
        }
        headerLabel.textColor = theme.titleTextColor
        for v in [titleLabel, tagsLabel, descriptionLabel, imagesLabel] {
            v?.textColor = theme.subtitleTextColor
        }
        titleField?.textColor = theme.titleTextColor
        titleField?.attributedPlaceholder = NSAttributedString(string: titleField!.placeholder ?? "",
            attributes: [
                NSForegroundColorAttributeName: theme.footnoteTextColor,
                NSFontAttributeName: titleField!.font!])
        tagsField?.textField.textColor = theme.subtitleTextColor
        tagsField?.textField.font = UIFont.systemFontOfSize(14)
        bodyField.textColor = theme.bodyTextColor
        bodyField.attributedPlaceholder = NSAttributedString(string: bodyField.placeholder ?? "",
            attributes: [
                NSForegroundColorAttributeName: theme.footnoteTextColor,
                NSFontAttributeName: bodyField.font!])
        separator.backgroundColor = theme.borderColorA
        publishButton.addTarget(self, action: "publish", forControlEvents: .TouchUpInside)
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        publishButton.backgroundColor = theme.backgroundColorB
        publishButton.setTitleColor(theme.subtitleTextColor, forState: .Normal)
        for v in [publishButton, dismissButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
            v.msr_borderColor = theme.borderColorA
        }
//        for v in [UITextInputTraits?](arrayLiteral: titleField, tagsField?.textField, bodyField) {
//            'v?.keyboardAppearance = theme.keyboardAppearance'
//            // 'Optional Protocol Setter Requirements' is not supported in Swift 1.2.
//            // See The Swift Programming Language book - Optional Protocol Requirements
//        }
        tagsField?.textField.keyboardAppearance = theme.keyboardAppearance
        for v in [UITextView?](arrayLiteral: titleField, bodyField) {
            v?.keyboardAppearance = theme.keyboardAppearance
        }
        scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
        scrollView.delaysContentTouches = false
        scrollView.scrollIndicatorInsets.top = 20
        scrollView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        let tap = UITapGestureRecognizer(target: self, action: "didTouchBlankArea")
        scrollView.addGestureRecognizer(tap)
        for identifier in SelfType.identifiers {
            imageCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        tagsField?.reloadData()
        imageCollectionView.reloadData()
    }
    
    // MARK: - ZFTokenFieldDataSource
    
    func lineHeightForTokenField(tokenField: ZFTokenField!) -> CGFloat {
        return 24
    }
    
    func numberOfTokensInTokenField(tokenField: ZFTokenField!) -> Int {
        return tags.count
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: Int) -> UIView! {
        let tag = tags[index]
        let theme = SettingsManager.defaultManager.currentTheme
        let label = UILabel()
        label.text = tag
        label.textColor = theme.subtitleTextColor
        label.font = UIFont.systemFontOfSize(14)
        label.sizeToFit()
        label.frame.size.height = lineHeightForTokenField(tagsField)
        label.frame.size.width += 20
        label.textAlignment = .Center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.backgroundColor = theme.backgroundColorA
        return label
    }
    
    // MARK: - ZFTokenFieldDelegate
    
    func tokenMarginForTokenField(tokenField: ZFTokenField!) -> CGFloat {
        return 5
    }
    
    func tokenField(tokenField: ZFTokenField!, didRemoveTokenAtIndex index: Int) {
        tags.removeAtIndex(index)
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        tags.append(text)
        tokenField?.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === tagsField?.textField {
            if textField.text ?? "" == "" {
                return false
            }
            for tag in tags {
                if tag == textField.text {
                    return false
                }
            }
            return true
        }
        return true
    }
    
    func tokenFieldDidReloadData(tokenField: ZFTokenField!) {
        let theme = SettingsManager.defaultManager.currentTheme
        tagsField?.textField.attributedPlaceholder = NSAttributedString(string: tags.count > 0 ? "..." : "输入并以换行键添加，可添加多个", attributes: [NSForegroundColorAttributeName: theme.footnoteTextColor])
    }
    
    // MARK: - UICollectionDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let theme = SettingsManager.defaultManager.currentTheme
        let cell: UICollectionViewCell!
        if indexPath.item < images.count {
            let image = images[indexPath.item]
            let maxProgress = self.maxProgress
            let uploadingProgress = Int(uploadingProgresses[indexPath.item])
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(SelfType.identifiers[0], forIndexPath: indexPath) 
            var imageView: UIImageView! = cell.contentView.viewWithTag(SelfType.imageViewTag) as? UIImageView
            if imageView == nil {
                imageView = UIImageView()
                imageView.tag = SelfType.imageViewTag
                cell.contentView.addSubview(imageView)
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.msr_addAllEdgeAttachedConstraintsToSuperview()
            }
            imageView!.image = image
            var overlayView: UIView! = cell.contentView.viewWithTag(SelfType.overlayViewTag)
            if overlayView == nil {
                overlayView = UIView()
                overlayView.tag = SelfType.overlayViewTag
                cell.contentView.insertSubview(overlayView, aboveSubview: imageView)
                overlayView.translatesAutoresizingMaskIntoConstraints = false
                overlayView.msr_addAllEdgeAttachedConstraintsToSuperview()
                overlayView.backgroundColor = scrollView.backgroundColor!.colorWithAlphaComponent(0.7)
            }
            var progressView: EAColourfulProgressView! = cell.contentView.viewWithTag(SelfType.progressViewTag) as? EAColourfulProgressView
            if progressView == nil {
                progressView = NSBundle.mainBundle().loadNibNamed("ImageUploadingProgressBar", owner: nil, options: nil).first as! EAColourfulProgressView
                progressView.tag = SelfType.progressViewTag
                progressView.translatesAutoresizingMaskIntoConstraints = false
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
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(SelfType.identifiers[1], forIndexPath: indexPath) 
            var button: UIButton! = cell.contentView.viewWithTag(SelfType.buttonTag) as? UIButton
            if button == nil {
                button = UIButton()
                button.msr_borderColor = theme.borderColorA
                button.msr_borderWidth = 0.5
                button.tag = SelfType.buttonTag
                cell.contentView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.msr_addAllEdgeAttachedConstraintsToSuperview()
                button.setImage(UIImage(named: "Publishment-Attachment"), forState: .Normal)
                button.imageView!.tintColor = theme.backgroundColorB
                button.adjustsImageWhenHighlighted = false
                button.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
                button.addTarget(self, action: "showImagePickerController", forControlEvents: .TouchUpInside)
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
                    if let index = self_.images.indexOf(image) {
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
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        SVProgressHUD.show()
        picker.dismissViewControllerAnimated(true, completion: nil)
        converting = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var images = [info[UIImagePickerControllerOriginalImage] as! UIImage].map {
                (image: UIImage) -> UIImage in
                let scale = min(1, min(SelfType.maxImageSideLength / image.size.width, SelfType.maxImageSideLength / image.size.height))
                let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                return image.msr_imageOfSize(size)
            }
            let uploadingProgress = [0]
            let uploaded = [false]
            let attachIDs = [SelfType.notAnAttachID]
            let jpegs = images.map {
                return UIImageJPEGRepresentation($0, SelfType.imageCompressionQuality)
            }
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                if let self_ = self {
                    self_.images.appendContentsOf(images)
                    self_.uploadingProgresses.appendContentsOf(uploadingProgress)
                    self_.allUploaded.lock()
                    self_.uploaded.appendContentsOf(uploaded)
                    self_.allUploaded.unlock()
                    self_.attachIDs.appendContentsOf(attachIDs)
                    for i in 0..<images.count {
                        let image = images[i]
                        let jpeg = jpegs[i]
                        let operation = self_.dataObject.uploadImageWithJPEGData(jpeg!,
                            success: {
                                attachID in
                                if let index = self_.images.indexOf(image) {
                                    self_.attachIDs[index] = attachID
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
                                var message = error.userInfo[NSLocalizedDescriptionKey] as? String
                                if message == nil && error.code != NSURLErrorCancelled {
                                    message = "未知错误。"
                                }
                                if message != nil {
                                    let ac = UIAlertController(title: "上传失败", message: message!, preferredStyle: .Alert) // Needs localization
                                    ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                                    self_.presentViewController(ac, animated: true, completion: nil)
                                }
                                if let index = self_.images.indexOf(image) {
                                    self_.removeDataAtIndex(index)
                                    self_.imageCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
                                }
                                return
                        })
                        operation.setUploadProgressBlock() {
                            bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            if let index = self_.images.indexOf(image) {
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
    
    @IBAction func showImagePickerController() {
        let ac = UIAlertController(title: "您想从哪里获取图片？", message: nil, preferredStyle: .ActionSheet)
        let ipc = UIImagePickerController()
        ipc.delegate = self
        ac.addAction(UIAlertAction(title: "相机", style: .Default) {
            [weak self] _ in
            ipc.sourceType = .Camera
            self?.showDetailViewController(ipc, sender: self)
            return
        })
        ac.addAction(UIAlertAction(title: "相簿", style: .Default) {
            [weak self] _ in
            ipc.sourceType = .PhotoLibrary
            self?.showDetailViewController(ipc, sender: self)
            return
        })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        showDetailViewController(ac, sender: self)
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
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    func didTouchBlankArea() {
        view.endEditing(true)
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
        if tagsField?.textField.text ?? "" != "" {
            tokenField(tagsField, didReturnWithText: tagsField!.textField.text)
        }
        let ac = UIAlertController(title: "再次确认", message: "您确定要发布吗？", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "是的", style: .Default)
            /* handler: */ {
                [weak self] action in
                if let self_ = self {
                    SVProgressHUD.show()
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
                                if let text = self_.titleField?.text {
                                    self_.dataObject.title = text
                                }
                                if self_.tagsField != nil {
                                    var topics = Set<Topic>()
                                    for tag in self_.tags {
                                        let topic = Topic.temporaryObject()
                                        topic.title = tag
                                        topics.insert(topic)
                                    }
                                    self_.dataObject.topics = topics
                                }
                                var body = self_.bodyField.text ?? ""
                                for id in self_.attachIDs {
                                    body += "\n[attach]\(id)[/attach]"
                                }
                                self_.dataObject.body = body
                                self_.dataObject.post(
                                    success: {
                                        question in
                                        SVProgressHUD.dismiss()
                                        SVProgressHUD.showSuccessWithStatus("已发布")
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                                            SVProgressHUD.dismiss()
                                            self_.delegate?.publishmentViewControllerDidSuccessfullyPublishDataObject?(self_)
                                            self_.dismissViewControllerAnimated(true, completion: nil)
                                        }
                                    },
                                    failure: {
                                        error in
                                        SVProgressHUD.dismiss()
                                        let ac = UIAlertController(title: "发布失败", message: error.userInfo[NSLocalizedDescriptionKey] as? String ?? "未知错误。", preferredStyle: .Alert)
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
    
    // MARK: - Keyboard Notification Observer
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let info = MSRAnimationInfo(keyboardNotification: notification)
        info.animate() {
            [weak self] in
            if let self_ = self {
                let bottom = UIScreen.mainScreen().bounds.height - info.frameEnd.minY
                self_.bottomConstraint.constant = bottom
                self_.view.layoutIfNeeded()
            }
            return
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
