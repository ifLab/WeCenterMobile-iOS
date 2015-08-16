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

class UserEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User {
        return User.currentUser!
    }
    weak var delegate: UserEditViewControllerDelegate?
    
    @IBOutlet weak var avatarImageView: MSRRoundedImageView!
    @IBOutlet weak var userNameTextView: UITextView!
    @IBOutlet weak var genderSegmentedControl: MSRSegmentedControl!
    @IBOutlet weak var signatureTextView: UITextView!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var signatureLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
        scrollView.scrollIndicatorInsets.top = 20
        scrollView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        signatureTextView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        for v in [userNameTextView, signatureTextView] {
            v.keyboardAppearance = theme.keyboardAppearance
        }
        uploadButton.backgroundColor = theme.backgroundColorA.colorWithAlphaComponent(0.5)
        uploadButton.setTitleColor(theme.subtitleTextColor, forState: .Normal)
        for v in [uploadButton, doneButton, dismissButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        titleLabel.textColor = theme.titleTextColor
        for v in [avatarLabel, userNameLabel, signatureLabel, genderLabel, birthdayLabel] {
            v.textColor = theme.subtitleTextColor
        }
        separator.backgroundColor = theme.borderColorA
        for v in [userNameTextView, signatureTextView, birthdayTextField, doneButton, dismissButton] {
            v.msr_borderColor = theme.borderColorA
        }
        for v in [userNameTextView, signatureTextView, doneButton, birthdayTextField, doneButton] {
            v.backgroundColor = theme.backgroundColorB
        }
        for v in [userNameTextView, signatureTextView] {
            v.textColor = theme.subtitleTextColor
        }
        birthdayTextField.textColor = theme.subtitleTextColor
        doneButton.setTitleColor(theme.titleTextColor, forState: .Normal)
        let indicator = MSRSegmentedControlCircleIndicator()
        indicator.fillColor = theme.backgroundColorB
        indicator.borderColor = theme.borderColorA
        indicator.borderWidth = 0.5
        genderSegmentedControl.indicator = indicator
        let maleSegment = MSRDefaultSegment(title: nil, image: UIImage(named: "User-Gender-Male"))
        let secretSegment = MSRDefaultSegment(title: "保密", image: nil)
        let femaleSegment = MSRDefaultSegment(title: nil, image: UIImage(named: "User-Gender-Female"))
        genderSegmentedControl.setSegments([maleSegment, secretSegment, femaleSegment], animated: false)
        maleSegment.tintColor = UIColor.msr_materialBlue()
        secretSegment.tintColor = theme.subtitleTextColor
        secretSegment.titleLabel.font = UIFont.systemFontOfSize(12)
        femaleSegment.tintColor = UIColor.msr_materialPink()
        let tap = UITapGestureRecognizer(target: self, action: "didTouchBlankArea")
        scrollView.addGestureRecognizer(tap)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        reloadData()
    }
    
    func reloadData() {
        avatarImageView.image = user.avatar
        userNameTextView.text = user.name
        signatureTextView.text = user.signature
        birthdayTextField.text = dateFormatter.stringFromDate(user.birthday ?? NSDate())
        genderSegmentedControl.selectedSegmentIndex = user.gender == nil || user.gender == .Secret ? 1 : user.gender == .Male ? 0 : 2
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
        user.name = userNameTextView.text
        let genders: [User.Gender] = [.Male, .Secret, .Female]
        user.gender = genders[genderSegmentedControl.selectedSegmentIndex!]
        user.signature = signatureTextView.text ?? ""
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
    
    func didTouchBlankArea() {
        view.endEditing(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
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
