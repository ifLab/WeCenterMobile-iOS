//
//  ButtonTouchesCancelableScrollView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import DTCoreText
import UIKit

class ButtonTouchesCancelableScrollView: UIScrollView {
    
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancelInContentView(view)
    }
    
}

class ButtonTouchesCancelableTableView: UITableView {
    
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancelInContentView(view)
    }
    
}

class ButtonTouchesCancelableCollectionView: UICollectionView {
    
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancelInContentView(view)
    }
    
}

class ButtonTouchesCancelableAttributedTextView: DTAttributedTextView {
    
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancelInContentView(view)
    }
    
}
