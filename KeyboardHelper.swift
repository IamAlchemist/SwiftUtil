//
//  KeyboardHelper.swift
//  ZaChatiOS
//
//  Created by wizard lee on 10/27/16.
//  Copyright © 2016 zhongan. All rights reserved.
//

import UIKit

class KeyboardHelper {
    let inputArea: UIView
    let scrollView: UIScrollView
    let rootView: UIView
    let bottomMargin: CGFloat
    
    var originInset: UIEdgeInsets?
    
    init(rootView: UIView, scrollView: UIScrollView, inputView: UIView, bottomMargin: CGFloat) {
        self.inputArea = inputView
        self.rootView = rootView
        self.scrollView = scrollView
        self.bottomMargin = bottomMargin
    }
    
    func registerToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func removeFromNoticationCenter() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let scrollVisibleArea = scrollView.convert(scrollView.frame, to: rootView)
            
            print("scroll frame in root view : \(scrollVisibleArea)")
            
            let rootViewVisible = CGRect(x: rootView.bounds.origin.x,
                                         y: rootView.bounds.origin.y,
                                         width: rootView.bounds.width,
                                         height: rootView.bounds.height - bottomMargin)
            
            print("root visible area : \(rootViewVisible)")
            
            let visibleArea = rootViewVisible.intersection(scrollVisibleArea).intersection(rect)
            
            print("visible area : \(visibleArea)")
            
            let inputArea = self.inputArea.convert(self.inputArea.bounds, to: rootView)
            
            print("input area : \(inputArea)")
            
            if !visibleArea.contains(inputArea) {
                
                var inset = scrollView.contentInset
                originInset = inset
                
                print("diff is : \(inputArea.maxY - visibleArea.maxY)")
                inset.bottom += inputArea.maxY - visibleArea.maxY
                
                scrollView.contentInset = inset
                
                print("scrollview inset : \(scrollView.contentInset)")
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let originInset = originInset {
            scrollView.contentInset = originInset
        }
    }

}
