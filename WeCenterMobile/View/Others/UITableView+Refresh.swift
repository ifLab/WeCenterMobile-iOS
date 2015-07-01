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
    func wc_addRefreshingHeaderWithTarget(target: AnyObject, action: Selector) -> MJRefreshNormalHeader {
        let theme = SettingsManager.defaultManager.currentTheme
        let header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
        self.header = header
        header.autoChangeAlpha = true
        header.lastUpdatedTimeLabel.textColor = theme.footnoteTextColor
        header.lastUpdatedTimeLabel.font = UIFont.boldSystemFontOfSize(12)
        header.stateLabel.textColor = theme.footnoteTextColor
        header.stateLabel.font = UIFont.boldSystemFontOfSize(12)
        wc_headerImageView = header.valueForKey("arrowView") as! UIImageView
        wc_headerImageView.tintColor = theme.footnoteTextColor
        wc_headerActivityIndicatorView = header.valueForKey("loadingView") as! UIActivityIndicatorView
        wc_headerActivityIndicatorView.activityIndicatorViewStyle = .White
        wc_headerActivityIndicatorView.color = theme.footnoteTextColor
        return header
    }
    func wc_addRefreshingFooterWithTarget(target: AnyObject, action: Selector) -> MJRefreshAutoNormalFooter {
        let theme = SettingsManager.defaultManager.currentTheme
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
        self.footer = footer
        footer.stateLabel.textColor = theme.footnoteTextColor
        footer.stateLabel.font = UIFont.boldSystemFontOfSize(12)
        footer.automaticallyRefresh = false
        wc_footerActivityIndicatorView = footer.valueForKey("loadingView") as! UIActivityIndicatorView
        wc_footerActivityIndicatorView.activityIndicatorViewStyle = .White
        wc_footerActivityIndicatorView.color = theme.footnoteTextColor
        return footer
    }
}
