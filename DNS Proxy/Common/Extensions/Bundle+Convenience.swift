//
//  Bundle+Convenience.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation

extension Bundle {
    func name() -> String {
        guard let name = infoDictionary?[kCFBundleNameKey as String] as? String else {
            assertionFailure("\(self) name is missing")
            return ""
        }
        return name
    }
}
