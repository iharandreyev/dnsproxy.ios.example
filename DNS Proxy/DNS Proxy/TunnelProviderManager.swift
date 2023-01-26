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

            manager.connection.startVPNTunnelIfNeeded { [weak self] error in
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
            
            manager.connection.stopVPNTunnelIfNeeded { [weak self] error in
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

extension NETunnelProviderManager {
    static func primary(_ completion: @escaping (Result<NETunnelProviderManager, Error>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, loadError in
            if let loadError {
                return completion(.failure(loadError))
            }
            
            if let primary = managers?.first {
                return completion(.success(primary))
            }
            
            let new = NETunnelProviderManager()
            new.saveToPreferences { saveError in
                if let saveError {
                    return completion(.failure(saveError))
                }
                
                return primary(completion)
            }
        }
    }
}

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

extension NEVPNConnection {
    private func addConnectionStatusObserver(_ body: @escaping (NEVPNStatus) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: self,
            queue: OperationQueue.main
        ) { [weak self] _ in
            guard let self else { return }
            body(self.status)
        }
    }
    
    private func removeConnectionStatusObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: .NEVPNStatusDidChange, object: self)
    }
    
    private func waitForConnectionStatus(
        _ expectedStatus: NEVPNStatus,
        completion: @escaping (Error?) -> Void
    ) {
        var completion: ((Error?) -> Void)? = completion
        var observation: NSObjectProtocol?
        var timeout: DispatchWorkItem?

        let finish = { [weak self] (error: Error?) in
            completion?(error)
            completion = nil
            timeout?.cancel()
            timeout = nil
            observation.map {  [weak self] in
                self?.removeConnectionStatusObserver($0)
                observation = nil
            }
        }

        observation = addConnectionStatusObserver { status in
            if status == expectedStatus {
                return finish(nil)
            }
            if status == .invalid {
                return finish(NSError.vpnError(code: .configurationInvalid))
            }
        }
        
        timeout = DispatchWorkItem {
            finish(NSError.timeout(thrownBy: Self.self))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeout!)
    }
    
    func startVPNTunnelIfNeeded(_ completion: @escaping (Error?) -> Void) {
        if status == .disconnected {
            do {
                try startVPNTunnel()
            } catch {
                return completion(error)
            }
        }
        
        waitForConnectionStatus(.connected, completion: completion)
    }
    
    func stopVPNTunnelIfNeeded(_ completion: @escaping (Error?) -> Void) {
        if status == .connected {
            stopVPNTunnel()
        }
        
        waitForConnectionStatus(.disconnected, completion: completion)
    }
}

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid: return "invalid"
        case .disconnected: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .reasserting: return "reasserting"
        case .disconnecting: return "disconnecting"
        @unknown default: return "unknown"
        }
    }
}

extension NSError {
    static func vpnError(code: NEVPNError.Code) -> NSError {
        NSError(domain: NEVPNError.errorDomain, code: code.rawValue)
    }
}
