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
    
    private var manager: NETunnelProviderManager?
    
    private override init() {
        super.init()
        enable(forced: true)
    }
    
    func enable(forced: Bool = false) {
        guard isEnabled == false || forced else { return }

        isEnabled = nil
        
        if let manager {
            Log("Will start tunnel")
            return enable(with: manager)
        }
 
        Log("Will load tunnel manager")
        
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, loadError in
            if let loadError {
                return Log("Can't retrieve tunnel manager: \(loadError)")
            }
            
            guard let manager = managers?.first else {
                return Log("No tunnel managers loaded")
            }
            
            self?.manager = manager
            
            Log("Did load tunnel manager")
            
            self?.enable(forced: true)
        }
    }
    
    private func enable(with manager: NETunnelProviderManager) {
        let proto = NETunnelProviderProtocol()
        proto.providerConfiguration = [:]
        proto.providerBundleIdentifier = Constants.tunnelProviderID
        proto.serverAddress = "localhost"
        proto.disconnectOnSleep = false
        
        manager.protocolConfiguration = proto
        manager.isEnabled = true
        manager.localizedDescription = Constants.tunnelProviderID
//        manager.onDemandRules = DNSConfig.google().onDemandRules
        
        manager.saveToPreferences { [weak self, weak manager] error in
            guard let self, let manager else {
                return Log("Error, objects deallocated")
            }
            
            if let error {
                return Log("Failed to save start preferences: \(error)")
            }

            manager.startVPN { [weak self] error in
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
        guard isEnabled == true, let manager else { return }
        
        isEnabled = nil
        
        Log("Will stop tunnel")
        disable(with: manager)
    }
    
    private func disable(with manager: NETunnelProviderManager) {
        manager.isEnabled = false
        
        manager.saveToPreferences { [weak self, weak manager] error in
            guard let self, let manager else {
                return Log("Error, objects deallocated")
            }
            
            if let error {
                Log("Failed to save stop preferences: \(error)")
                self.isEnabled = false
                return
            }
            
            manager.stopVPN { [weak self] error in
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
