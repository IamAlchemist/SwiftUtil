//
//  KeyboardHelper.swift
//
//  Created by wizard lee on 10/27/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit

class KeyboardHelper {
    weak var inputArea: UIView!
    weak var scrollView: UIScrollView!
    weak var rootView: UIView!
    let bottomMargin: CGFloat
    let shouldScroll: Bool
    
    var originInset: UIEdgeInsets?
    
    var debug = false
    
    init(rootView: UIView, scrollView: UIScrollView, inputView: UIView, bottomMargin: CGFloat = 0, shouldScroll: Bool = false) {
        self.inputArea = inputView
        self.rootView = rootView
        self.scrollView = scrollView
        self.bottomMargin = bottomMargin
        self.shouldScroll = shouldScroll
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
            if originInset != nil { return }
            
            originInset = scrollView.contentInset
            var inset = scrollView.contentInset
            inset.bottom += rect.height
            scrollView.contentInset = inset
            
            if shouldScroll {
                scrollView.scrollRectToVisible(inputArea.frame, animated: false)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let originInset = originInset {
            scrollView.contentInset = originInset
            self.originInset = nil
        }
    }
    
    func printDebug(_ message: String) {
        if debug {
            print(message)
        }
    }
}
