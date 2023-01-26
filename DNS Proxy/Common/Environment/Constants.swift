//
//  Constants.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation

enum Constants {
    static var bundleName: String {
        Bundle.main.name()
    }
    
    static var tunnelProviderID: String {
        "example.dns.proxy.DNS-Packet-Tunnel-Extension"
    }
}
