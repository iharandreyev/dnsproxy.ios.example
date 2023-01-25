//
//  NSError+Extension.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import Foundation

extension NSError {
    static func unknown<T>(thrownBy objectType: T.Type) -> NSError {
        NSError(domain: "\(objectType)", code: -1)
    }
    
    static func cancel<T>(thrownBy objectType: T.Type) -> NSError {
        NSError(domain: "\(objectType)", code: -999, userInfo: [NSLocalizedDescriptionKey: "Cancelled"])
    }
}
