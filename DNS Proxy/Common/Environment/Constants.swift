//
//  Constants.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation

enum Constants {
    static var bundleName: String {
        guard let name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String else {
            assertionFailure("Bundle name is missing")
            return ""
        }
        return name
    }
    
    static var tunnelProviderID: String {
        "example.dns.proxy.DNS-Packet-Tunnel-Extension"
    }
}
