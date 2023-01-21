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
    private var isEnabledObserver: Timer?
    
    @Published
    private(set) var isEnabled: Bool? = nil

    override init() {
        super.init()
        enable()
    }
    
    func enable() {
        manager.updateConfiguration { [weak self] manager in
            self?.enable(manager)
        } completion: { [weak self] result in
            switch result {
            case let .success(manager):
                self?.syncState(with: manager)
                self?.observeIsEnabledIfNeeded()
            case let .failure(error):
                Log("Proxy enable failed: \(error)")
            }
        }
    }
    
    private func enable(_ manager: NEDNSProxyManager) {
        manager.localizedDescription = proxyName
        manager.providerProtocol = createProxyProtocol()
        manager.isEnabled = true
    }
    
    private func createProxyProtocol() -> NEDNSProxyProviderProtocol {
        let proto = NEDNSProxyProviderProtocol()
        // proto.providerConfiguration = +++
        proto.providerBundleIdentifier = ""
        return proto
    }

    func disable() {
        Log("Will disable proxy")
        manager.updateConfiguration { [weak self] manager in
            self?.disable(manager)
        } completion: { [weak self] result in
            switch result {
            case let .success(manager):
                self?.syncState(with: manager)
            case let .failure(error):
                Log("Proxy disable failed: \(error)")
            }
            
            self?.isEnabledObserver = nil
        }
    }

    private func disable(_ manager: NEDNSProxyManager) {
        manager.providerProtocol = nil
        manager.isEnabled = false
    }
    
    private func syncState(with manager: NEDNSProxyManager) {
        DispatchQueue.main.async { [weak self] in
            self?.setIsEnabled(manager.isEnabled)
        }
    }
    
    private func setIsEnabled(_ isEnabled: Bool) {
        guard self.isEnabled != isEnabled else { return }
        self.isEnabled = isEnabled
        Log("Proxy \(isEnabled ? "enabled" : "disabled")")
    }
    
    private func observeIsEnabledIfNeeded() {
        guard case .none = isEnabledObserver else { return }
        isEnabledObserver = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.updateIsEnabled()
        }
    }
    
    private func updateIsEnabled() {
        let manager = manager
        manager.loadFromPreferences { [weak self] error in
            switch error {
            case .none:
                self?.syncState(with: manager)
            case let .some(error):
                Log("\(error)")
            }
        }
    }
}
