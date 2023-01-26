//
//  NSError+NEVPNError.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation
import NetworkExtension

extension NSError {
    convenience init(vpnErrorCode: NEVPNError.Code) {
        self.init(domain: NEVPNError.errorDomain, code: vpnErrorCode.rawValue)
    }
}
