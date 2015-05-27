//
//  TableViewWithKeyboardBar.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/28.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class TableViewWithKeyboardBar: UITableView {
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canResignFirstResponder() -> Bool {
        return true
    }
    
    private var _inputAccessoryView: KeyboardBar! = nil
    
    override var inputAccessoryView: KeyboardBar {
        if _inputAccessoryView == nil {
            _inputAccessoryView = KeyboardBar(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 44))
        }
        return _inputAccessoryView
    }
    
}
