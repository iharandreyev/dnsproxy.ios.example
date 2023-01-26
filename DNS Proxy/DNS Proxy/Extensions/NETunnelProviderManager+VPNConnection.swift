//
//  NEVPNConnection+Convenience.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation
import NetworkExtension

extension NETunnelProviderManager {
    private func addConnectionStatusObserver(_ body: @escaping (NEVPNStatus) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: connection,
            queue: OperationQueue.main
        ) { [weak connection] _ in
            guard let connection else { return }
            body(connection.status)
        }
    }
    
    private func removeConnectionStatusObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: .NEVPNStatusDidChange, object: connection)
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
                return finish(NEVPNError(.configurationInvalid))
            }
        }
        
        timeout = DispatchWorkItem {
            finish(NSError.timeout(thrownBy: Self.self))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeout!)
    }
    
    func startVPN(_ completion: @escaping (Error?) -> Void) {
        if connection.status == .disconnected {
            do {
                try connection.startVPNTunnel()
            } catch {
                return completion(error)
            }
        }
        
        waitForConnectionStatus(.connected, completion: completion)
    }
    
    func stopVPN(_ completion: @escaping (Error?) -> Void) {
        if connection.status == .connected {
            connection.stopVPNTunnel()
        }
        
        waitForConnectionStatus(.disconnected, completion: completion)
    }
}
