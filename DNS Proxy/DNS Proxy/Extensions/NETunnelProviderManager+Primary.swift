//
//  NETunnelProviderManager+Primary.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation
import NetworkExtension

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
