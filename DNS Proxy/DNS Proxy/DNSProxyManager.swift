//
//  DNSProxyManager.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import NetworkExtension

final class DNSProxyManager: NSObject, ObservableObject {
    private let manager = NEDNSProxyManager.shared()
    
    private let proxyName = "DNS Proxy"
    
    @Published
    private(set) var isEnabled: Bool? = nil
    
    static let shared = DNSProxyManager()

    private override init() {
        super.init()
        enable()
    }
    
    func enable() {
        manager.updateConfiguration { [unowned self] manager in
            manager.localizedDescription = proxyName
            manager.providerProtocol = createProxyProtocol()
            manager.isEnabled = true
        } completion: { [unowned self] result in
            switch result {
            case let .success(manager):
                syncState(with: manager)
            case let .failure(error):
                Log("Proxy enable failed: \(error)")
            }
        }
    }
    
    private func createProxyProtocol() -> NEDNSProxyProviderProtocol {
        let proto = NEDNSProxyProviderProtocol()
        // proto.providerConfiguration = +++
        proto.providerBundleIdentifier = "example.dns.proxy.DNS-Proxy-Extension"
        return proto
    }

    func disable() {
        Log("Will disable proxy")
        manager.updateConfiguration { manager in
            manager.providerProtocol = nil
            manager.isEnabled = false
        } completion: { [unowned self] result in
            switch result {
            case let .success(manager):
                syncState(with: manager)
            case let .failure(error):
                Log("Proxy disable failed: \(error)")
            }
        }
    }

    private func syncState(with manager: NEDNSProxyManager) {
        DispatchQueue.main.async { [unowned self] in
            setIsEnabled(manager.isEnabled)
        }
    }
    
    private func setIsEnabled(_ isEnabled: Bool) {
        guard self.isEnabled != isEnabled else { return }
        self.isEnabled = isEnabled
        Log("Proxy \(isEnabled ? "enabled" : "disabled")")
    }
}
