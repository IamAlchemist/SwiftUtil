//
//  TouchableView.swift
//
//  Created by wizard lee on 10/28/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol TouchableViewDelegate {
    func touchableViewTapped(view: TouchableView)
}

class TouchableView: UIView {
    private var coverView: UIView!
    
    weak var delegate: TouchableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @IBInspectable var coverTintColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2) {
        didSet {
            coverView?.backgroundColor = coverTintColor
        }
    }
    
    func tapped(gesture: UIGestureRecognizer) {
        delegate?.touchableViewTapped(view: self)
    }
    
    private func setup() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(gesture:))))
        
        coverView = UIImageView(frame: CGRect.zero)
        coverView.isUserInteractionEnabled = false
        coverView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        addSubview(coverView)
        
        coverView.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }

        coverView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        coverView.isHidden = false
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        coverView.isHidden = true
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        coverView.isHidden = true
        super.touchesEnded(touches, with: event)
    }
}

