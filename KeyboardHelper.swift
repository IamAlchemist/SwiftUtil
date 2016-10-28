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
    
    var debug = false
    
    init(rootView: UIView, scrollView: UIScrollView, inputView: UIView, bottomMargin: CGFloat = 0) {
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
            
            let padding = max(scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom - scrollView.contentSize.height, 0)
            
            printDebug("padding = \(padding), contentSize: \(scrollView.contentSize)")
            
            let scrollVisibleArea = scrollView.convert(scrollView.frame, to: rootView)
            
            printDebug("scroll frame in root view : \(scrollVisibleArea)")
            
            let rootViewVisible = CGRect(x: rootView.bounds.origin.x,
                                         y: rootView.bounds.origin.y,
                                         width: rootView.bounds.width,
                                         height: rootView.bounds.height)
            
            printDebug("root visible area : \(rootViewVisible)")
            
            printDebug("keyboard size : \(rect)")
            
            var visibleArea = rootViewVisible.intersection(scrollVisibleArea)
            
            printDebug("intersected keyboard size : \(visibleArea)")
            
            visibleArea = CGRect(origin: visibleArea.origin, size: CGSize(width: visibleArea.width, height: visibleArea.height - rect.height))
            
            printDebug("visible area : \(visibleArea)")
            
            let inputArea = self.inputArea.convert(self.inputArea.bounds, to: rootView)
            
            printDebug("input area : \(inputArea)")
            
            if !visibleArea.contains(inputArea) {
                
                var inset = scrollView.contentInset
                originInset = inset
                
                printDebug("origin inset : \(inset)")
                
                printDebug("diff is : \(inputArea.maxY - visibleArea.maxY)")
                inset.bottom += inputArea.maxY - visibleArea.maxY + padding + bottomMargin
                
                scrollView.contentInset = inset
                
                printDebug("scrollview inset : \(scrollView.contentInset)")
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let originInset = originInset {
            scrollView.contentInset = originInset
        }
    }
    
    func printDebug(_ message: String) {
        if debug {
            print(message)
        }
    }
}
