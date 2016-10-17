//
//  FrameworkExtension.swift
//  ZaChatiOS
//
//  Created by wizard lee on 10/17/16.
//  Copyright © 2016 zhongan. All rights reserved.
//

import UIKit

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}
