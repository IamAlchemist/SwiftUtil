//
//  UIKitHelper.swift
//  ZaChatiOS
//
//  Created by wizard lee on 11/9/16.
//  Copyright © 2016 zhongan. All rights reserved.
//

import UIKit

struct MWUIKitHelper {
    static func toolBarFor(target: Any?, action:Selector) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolBar.tintColor = UIColor.gray
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: target, action: action)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [space, doneBtn]
        
        return toolBar
    }
}
