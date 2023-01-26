//
//  DNSConfig.swift
//  DNS Settings
//
//  Created by Andreyeu, Ihar on 1/23/23.
//

import NetworkExtension

enum DNSProvider: Int, CaseIterable, Hashable, CustomStringConvertible {
    case quad9 = 0
    case google
    
    var description: String {
        switch self {
        case .quad9: return "Quad9"
        case .google: return "Google"
        }
    }
    
    static var `default`: Self { .quad9 }
    
    var next: Self {
        var next = rawValue + 1
        if next > Self.allCases.last!.rawValue {
            next = 0
        }
        return .init(rawValue: next)!
    }
}

struct DNSConfig: Equatable {
    /// An object that contains the configuration settings for a DNS server.
    var settings: NEDNSSettings?
    /// A string that contains the display name of the DNS settings configuration.
    var localizedDescription: String?
    /// A list of ordered rules that defines the networks on which the DNS settings will apply.
    var onDemandRules: [NEOnDemandRule]?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        // TODO: - Update
        guard lhs.localizedDescription == rhs.localizedDescription else { return false }
        guard lhs.settings?.servers == rhs.settings?.servers else { return false }
        guard lhs.onDemandRules?.count == rhs.onDemandRules?.count else { return false }
        return true
    }
}

extension DNSConfig {
    static func quad9() -> DNSConfig {
        // DNS over HTTPS server URL. Mandatory
        let serverURL: URL = "https://dns.quad9.net/dns-query"
        
        let validIPs: [String] = ["9.9.9.9"]//, "149.112.112.112", "2620:fe::fe", "2620:fe::fe:9"]
        let invalidIPs: [String] = ["255.254.253.252"]
        
        // Ip addresses of dns servers
        // An ordered list of address, if the previous one can't be accessed, the next one is used
        // Empty list behavior has not been researched
        let servers = invalidIPs + validIPs
        
        let settings = NEDNSOverHTTPSSettings(servers: servers)
        settings.serverURL = serverURL
        
        var config = DNSConfig()
        config.settings = settings
        config.localizedDescription = "Quad9"
        
        config.onDemandRules = .testRules()
        
        return config
    }
    
    static func google() -> DNSConfig {
        // DNS over HTTPS server URL. Mandatory
        let serverURL: URL = "https://dns.google/dns-query"
        
        // Ip addresses of dns servers
        // An ordered list of address, if the previous one can't be accessed, the next one is used
        // Empty list behavior has not been researched
        let dnsIPS: [String] = ["8.8.8.8"]//, "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"]

        let settings = NEDNSOverHTTPSSettings(servers: dnsIPS)
        settings.serverURL = serverURL
        
        var config = DNSConfig()
        config.settings = settings
        config.localizedDescription = "Google"
        
        config.onDemandRules = .testRules()
        
        return config
    }
}

private extension Array where Element == NEOnDemandRule {
    static func testRules() -> Self {
        // Some domains should be accessed using only local DNS-provider
        // https://www.wwdcnotes.com/notes/wwdc20/10047/
        let internalDomains = NEOnDemandRuleEvaluateConnection()
        internalDomains.interfaceTypeMatch = .any
        internalDomains.connectionRules = [
            NEEvaluateConnectionRule(
                matchDomains: [
                    "https://ipleak.net",
                    "ipleak.net",
                    "ipleak"
                ],
                andAction: .neverConnect)
        ]
        let enableByDefault = NEOnDemandRuleConnect()
        /*
         https://www.top10vpn.com/tools/what-is-my-dns-server/ should show the selected dns provider servers
         https://ipleak.net should show local ISP dns
         enableByDefault - use the provided dns servers for everything except the previous rules
         */
        
        return [
            internalDomains,
            enableByDefault
        ]
    }
}
