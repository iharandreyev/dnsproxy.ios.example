//
//  TunnelOption.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation
import NetworkExtension

enum TunnelOption: String {
    case tunnelRemoteAddress
    case dnsSettings
}

final class TunnelOptions {
    let tunnelRemoteAddress: String
    let dnsSettings: NEDNSOverHTTPSSettings
    
    init(
        tunnelRemoteAddress: String,
        dnsSettings: NEDNSOverHTTPSSettings
    ) {
        self.tunnelRemoteAddress = tunnelRemoteAddress
        self.dnsSettings = dnsSettings
    }
    
    convenience init(tunnelOptions: [String: NSObject]?) throws {
        guard let tunnelOptions else {
            throw TunnelOptionsError.noOptions
        }
        guard let tunnelRemoteAddress: NSString = tunnelOptions.value(forKey: TunnelOption.tunnelRemoteAddress) else {
            throw TunnelOptionsError.noTunnelRemoteAddress
        }
        guard let dnsSettings: NEDNSOverHTTPSSettings = tunnelOptions.value(forKey: TunnelOption.dnsSettings) else {
            throw TunnelOptionsError.noDnsSettings
        }
        self.init(
            tunnelRemoteAddress: tunnelRemoteAddress as String,
            dnsSettings: dnsSettings
        )
    }
    
    func eraseToAnyDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary.setValue(NSString(string: tunnelRemoteAddress), forKey: TunnelOption.tunnelRemoteAddress)
        dictionary.setValue(dnsSettings, forKey: TunnelOption.dnsSettings)
        return dictionary
    }
}

enum TunnelOptionsError: Error {
    case noOptions
    case noTunnelRemoteAddress
    case noDnsSettings
}

private extension Dictionary {
    mutating func setValue<Key: RawRepresentable>(
        _ value: Value,
        forKey key: Key
    ) where Key.RawValue == Self.Key {
        self[key.rawValue] = value
    }
    
    func value<Value, Key: RawRepresentable>(
        ofType type: Value.Type = Value.self,
        forKey key: Key
    ) -> Value? where Key.RawValue == Self.Key {
        self[key.rawValue] as? Value
    }
}
