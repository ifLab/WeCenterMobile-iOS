//
//  AnswerBottomBar.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/4.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class AnswerBottomBar: UIVisualEffectView {
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.adjustsImageWhenHighlighted = false
        commentButton.adjustsImageWhenHighlighted = false
        shareButton.setImage(shareButton.imageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        commentButton.setImage(commentButton.imageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        
        shareButton.msr_setBackgroundImageWithColor(UIColor.whiteColor().colorWithAlphaComponent(0.2), forState: .Highlighted)
        commentButton.msr_setBackgroundImageWithColor(UIColor.whiteColor().colorWithAlphaComponent(0.2), forState: .Highlighted)
        msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        msr_addHeightConstraintWithValue(50)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if superview != nil {
            msr_removeHorizontalEdgeAttachedConstraintsFromSuperview()
        }
    }
    
    override func didMoveToSuperview() {
        if superview != nil {
            msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        }
    }

}
