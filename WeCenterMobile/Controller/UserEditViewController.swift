//
//  UserEditViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/26.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import RMDateSelectionViewController
import SVProgressHUD
import UIKit

@objc protocol UserEditViewControllerDelegate {
    optional func userEditViewControllerDidUpdateUserProfile(uevc: UserEditViewController)
}

class UserEditViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User {
        return User.currentUser!
    }
    weak var delegate: UserEditViewControllerDelegate?
    
    @IBOutlet weak var avatarImageView: MSRRoundedImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: MSRSegmentedControl!
    @IBOutlet weak var signatureTextView: UITextView!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.alwaysBounceVertical = true
        signatureTextView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        uploadButton.layer.masksToBounds = true
        uploadButton.layer.cornerRadius = uploadButton.bounds.width / 2
        uploadButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
        doneButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
        dismissButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
        userNameTextField.attributedPlaceholder = NSAttributedString(string: userNameTextField.placeholder ?? "", attributes: [
            NSFontAttributeName: userNameTextField.font,
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.4)])
        birthdayTextField.attributedPlaceholder = NSAttributedString(string: birthdayTextField.placeholder ?? "", attributes: [
            NSFontAttributeName: userNameTextField.font,
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.4)])
        genderSegmentedControl.indicator = MSRSegmentedControlCircleIndicator()
        let maleSegment = MSRDefaultSegment(title: nil, image: UIImage(named: "Male"))
        let secretSegment = MSRDefaultSegment(title: "保密", image: nil)
        let femaleSegment = MSRDefaultSegment(title: nil, image: UIImage(named: "Female"))
        genderSegmentedControl.setSegments([maleSegment, secretSegment, femaleSegment], animated: false)
        genderSegmentedControl.indicator.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        maleSegment.tintColor = UIColor.msr_materialBlue()
        secretSegment.tintColor = UIColor.whiteColor()
        secretSegment.titleLabel.font = UIFont.systemFontOfSize(12)
        femaleSegment.tintColor = UIColor.msr_materialPink()
        reloadData()
    }
    
    func reloadData() {
        avatarImageView.image = user.avatar
        userNameTextField.text = user.name
        signatureTextView.text = user.signature
        birthdayTextField.text = dateFormatter.stringFromDate(user.birthday ?? NSDate())
        genderSegmentedControl.selectedSegmentIndex = user.gender == nil || user.gender == .Secret ? 1 : user.gender == .Male ? 0 : 2
        scrollView.backgroundColor = TintColorFromColor(user.avatar?.msr_averageColorWithAccuracy(0.5)).colorWithAlphaComponent(0.3)
    }
    
    @IBAction func finish() {
        if uploadActivityIndicatorView.isAnimating() {
            let ac = UIAlertController(title: "提示", message: "请等待头像上传完成。", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
            showDetailViewController(ac, sender: self)
            return
        }
        let user = User.temporaryObject()
        user.id = self.user.id
        user.name = userNameTextField.text
        let genders: [User.Gender] = [.Male, .Secret, .Female]
        user.gender = genders[genderSegmentedControl.selectedSegmentIndex!]
        user.signature = signatureTextView.text
        user.birthday = dateFormatter.dateFromString(birthdayTextField.text)
        SVProgressHUD.showWithMaskType(.Gradient)
        user.updateProfileForCurrentUser(
            success: {
                [weak self] in
                SVProgressHUD.dismiss()
                self?.delegate?.userEditViewControllerDidUpdateUserProfile?(self!)
                self?.dismiss()
            },
            failure: {
                [weak self] error in
                SVProgressHUD.dismiss()
                let body = (error.userInfo?[NSLocalizedDescriptionKey] as? String) ?? "未知错误"
                let ac = UIAlertController(title: "错误", message: body, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self?.showDetailViewController(ac, sender: self)
                return
            })
    }
    
    @IBAction func dismiss() {
        if uploadActivityIndicatorView.isAnimating() {
            User.cancleAvatarUploadingOperation()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField === birthdayTextField {
            let dsvc = RMDateSelectionViewController(
                style: .White,
                title: "生日",
                message: "请选择日期。",
                selectAction: RMAction(title: "选择", style: .Done) {
                    [weak self] controller in
                    let controller = controller as! RMDateSelectionViewController
                    self?.birthdayTextField.text = self!.dateFormatter.stringFromDate(controller.datePicker.date)
                    return
                },
                andCancelAction: RMAction(title: "取消", style: .Cancel) { _ in })
            dsvc.disableBouncingEffects = true
            dsvc.disableMotionEffects = false
            dsvc.disableBlurEffects = false
            dsvc.datePicker.datePickerMode = .Date
            dsvc.datePicker.date = dateFormatter.dateFromString(birthdayTextField.text)!
            showDetailViewController(dsvc, sender: self)
            return false
        }
        return true
    }
    
    @IBAction func showImagePickerController() {
        let ipc = UIImagePickerController()
        ipc.delegate = self
        ipc.allowsEditing = true
        ipc.sourceType = .PhotoLibrary
        showDetailViewController(ipc, sender: self)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var avatar = info[UIImagePickerControllerEditedImage] as! UIImage
        println(info[UIImagePickerControllerCropRect])
        User.uploadAvatar(avatar,
            success: {
                [weak self] in
                self?.afterUploading()
                self?.reloadData()
                return
            },
            failure: {
                [weak self] error in
                self?.afterUploading()
                let body = (error.userInfo?[NSLocalizedDescriptionKey] as? String) ?? "未知错误"
                let ac = UIAlertController(title: "图片上传失败", message: body, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self?.showDetailViewController(ac, sender: self)
                return
            })
    }
    
    func beforeUploading() {
        uploadButton.enabled = false
        uploadButton.setTitle(nil, forState: .Normal)
        uploadActivityIndicatorView.startAnimating()
    }
    
    func afterUploading() {
        uploadButton.enabled = true
        uploadButton.setTitle("上传", forState: .Normal)
        uploadActivityIndicatorView.stopAnimating()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
