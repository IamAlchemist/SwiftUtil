//
//  Protocols.swift
//  ZaChatiOS
//
//  Created by wizard lee on 28/12/2016.
//  Copyright © 2016 zhongan. All rights reserved.
//

import Foundation

protocol Parameterable {
    var parameters: [String: Any] { get }
}

extension Parameterable {
    var parametersString: String? {
        get {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options:.prettyPrinted)
                return String(data: jsonData, encoding:.utf8)
            }
            catch let error as NSError {
                print("\(error.localizedDescription)")
            }
            
            return nil
        }
    }
}
