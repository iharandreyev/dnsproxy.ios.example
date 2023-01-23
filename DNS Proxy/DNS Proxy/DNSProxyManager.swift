//
//  DNSProxyManager.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import Combine
import NetworkExtension

final class DNSProxyManager: NSObject, ObservableObject {
    private let manager = NEDNSProxyManager.shared()
    
    private let proxyName = "DNS Proxy"
    
    @Published
    private(set) var isEnabled: Bool? = nil
    
    static let shared = DNSProxyManager()
    
    private var subs: Set<AnyCancellable> = []

    private override init() {
        super.init()
        enable()
        
        manager.isEnabledPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.setIsEnabled(isEnabled)
            })
            .store(in: &subs)
    }
    
    func enable() {
        manager.updateConfiguration { [unowned self] manager in
            manager.localizedDescription = proxyName
            manager.providerProtocol = createProxyProtocol()
            manager.isEnabled = true
        } completion: { result in
            guard case let .failure(error) = result else { return }
            Log("Proxy enable failed: \(error)")
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
            manager.isEnabled = false
        } completion: { result in
            guard case let .failure(error) = result else { return }
            Log("Proxy enable failed: \(error)")
        }
    }
    
    private func setIsEnabled(_ isEnabled: Bool) {
        guard self.isEnabled != isEnabled else { return }
        self.isEnabled = isEnabled
        Log("Proxy \(isEnabled ? "enabled" : "disabled")")
    }
}
