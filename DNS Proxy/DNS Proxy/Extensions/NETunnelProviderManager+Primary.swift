//
//  NETunnelProviderManager+Primary.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation
import NetworkExtension

extension NETunnelProviderManager {
    static func primary(_ completion: @escaping (Result<NETunnelProviderManager?, Error>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, loadError in
            if let loadError {
                return completion(.failure(loadError))
            }

            return completion(.success( managers?.first))
        }
    }
}
