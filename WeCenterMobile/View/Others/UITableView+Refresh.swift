//
//  UITableView+Refresh.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/6/4.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit

private var _UITableViewWCHeaderImageViewAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

private var _UITableViewWCHeaderActivityIndicatorViewAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

private var _UITableViewWCFooterActivityIndicatorViewAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

extension UITableView {
    private var wc_headerImageView: UIImageView! /* For keeping the weak property in header. */ {
        set {
            objc_setAssociatedObject(self, _UITableViewWCHeaderImageViewAssociationKey, newValue, objc_AssociationPolicy())
        }
        get {
            return objc_getAssociatedObject(self, _UITableViewWCHeaderImageViewAssociationKey) as? UIImageView
        }
    }
    private var wc_headerActivityIndicatorView: UIActivityIndicatorView! /* For keeping the weak property in header. */ {
        set {
            objc_setAssociatedObject(self, _UITableViewWCHeaderActivityIndicatorViewAssociationKey, newValue, objc_AssociationPolicy())
        }
        get {
            return objc_getAssociatedObject(self, _UITableViewWCHeaderActivityIndicatorViewAssociationKey) as? UIActivityIndicatorView
        }
    }
    private var wc_footerActivityIndicatorView: UIActivityIndicatorView! /* For keeping the weak property in footer. */ {
        set {
            objc_setAssociatedObject(self, _UITableViewWCFooterActivityIndicatorViewAssociationKey, newValue, objc_AssociationPolicy())
        }
        get {
            return objc_getAssociatedObject(self, _UITableViewWCFooterActivityIndicatorViewAssociationKey) as? UIActivityIndicatorView
        }
    }
    func wc_addLegendHeaderWithRefreshingTarget(target: AnyObject, action: Selector) -> MJRefreshLegendHeader {
        let header = addLegendHeaderWithRefreshingTarget(target, refreshingAction: action)
        let theme = SettingsManager.defaultManager.currentTheme
        header.textColor = theme.footnoteTextColor
        wc_headerImageView = header.valueForKey("arrowImage") as! UIImageView
        wc_headerImageView.tintColor = theme.footnoteTextColor
        wc_headerImageView.msr_imageRenderingMode = .AlwaysTemplate
        wc_headerActivityIndicatorView = header.valueForKey("activityView") as! UIActivityIndicatorView
        wc_headerActivityIndicatorView.activityIndicatorViewStyle = .White
        wc_headerActivityIndicatorView.color = theme.footnoteTextColor
        return header
    }
    func wc_addLegendFooterWithRefreshingTarget(target: AnyObject, action: Selector) -> MJRefreshLegendFooter {
        let theme = SettingsManager.defaultManager.currentTheme
        let footer = addLegendFooterWithRefreshingTarget(target, refreshingAction: action)
        footer.textColor = theme.footnoteTextColor
        footer.automaticallyRefresh = false
        wc_footerActivityIndicatorView = footer.valueForKey("activityView") as! UIActivityIndicatorView
        wc_footerActivityIndicatorView.activityIndicatorViewStyle = .White
        wc_footerActivityIndicatorView.color = theme.footnoteTextColor
        return footer
    }
}
