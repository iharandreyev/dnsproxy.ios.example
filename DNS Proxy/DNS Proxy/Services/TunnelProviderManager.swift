//
//  TunnelProviderManager.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Combine
import Foundation
import NetworkExtension

final class TunnelProviderManager: NSObject, ObservableObject {
    @Published
    private(set) var isEnabled: Bool? = nil
    
    static let shared = TunnelProviderManager()
    
    private override init() {
        super.init()
        enable(forced: true)
    }
    
    func enable(forced: Bool = false) {
        guard isEnabled == false || forced else { return }
        
        isEnabled = nil
        
        Log("Will enable tunnel")
        NETunnelProviderManager.primary { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                Log("Tunnel manager get failed: \(error)")
                self.isEnabled = false
                return
            case let .success(primary):
                self.enable(with: primary)
                return
            }
        }
    }
    
    private func enable(with manager: NETunnelProviderManager) {
        manager.protocolConfiguration = NETunnelProviderProtocol.preferred
        manager.isEnabled = true
        manager.localizedDescription = Constants.tunnelProviderID
//        manager.onDemandRules = DNSConfig.google().onDemandRules
        
        manager.saveToPreferences { [weak self, weak manager] error in
            guard let self, let manager else {
                return Log("Error, objects deallocated")
            }
            
            if let error {
                Log("Tunnel manager save before enable failed: \(error)")
            }

            manager.connection.startVPN { [weak self] error in
                guard let self else {
                    return Log("Error, object deallocated")
                }
                
                if let error {
                    Log("Failed to start tunnel: \(error)")
                    self.isEnabled = false
                    return
                }
                
                Log("Did start tunnel")
                self.isEnabled = true
            }
        }
    }
    
    func disable() {
        guard isEnabled == true else { return }
        
        isEnabled = nil
        
        Log("Will disable tunnel")
        
        NETunnelProviderManager.primary { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                Log("\(error)")
                self.isEnabled = false
                return
            case let .success(manager):
                self.disable(with: manager)
                return
            }
        }
    }
    
    private func disable(with manager: NETunnelProviderManager) {
        manager.isEnabled = false
        
        manager.saveToPreferences { [weak self, weak manager] error in
            guard let self, let manager else {
                return Log("Error, objects deallocated")
            }
            
            if let error {
                Log("Tunnel manager save before disable failed: \(error)")
                self.isEnabled = false
                return
            }
            
            manager.connection.stopVPN { [weak self] error in
                guard let self else {
                    return Log("Error, object deallocated")
                }
                
                if let error {
                    Log("Failed to stop tunnel: \(error)")
                    self.isEnabled = false
                    return
                }
                
                Log("Did stop tunnel")
                self.isEnabled = false
            }
        }
    }
}

extension NETunnelProviderProtocol {
    static let preferred: NETunnelProviderProtocol = {
        let proto = NETunnelProviderProtocol()
        proto.providerConfiguration = [:]
        proto.providerBundleIdentifier = Constants.tunnelProviderID
        proto.serverAddress = "localhost"
        proto.disconnectOnSleep = false
        return proto
    }()
}
