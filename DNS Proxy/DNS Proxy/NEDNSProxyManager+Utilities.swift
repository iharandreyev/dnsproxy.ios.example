//
//  NEDNSProxyManager+Utilities.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import NetworkExtension

extension NEDNSProxyManager {
    func updateConfiguration(_ body: @escaping (NEDNSProxyManager) -> Void, completion: @escaping (Result<NEDNSProxyManager, Error>) -> Void) {
        loadFromPreferences { [unowned self] error in
            if let error {
                completion(.failure(error))
                return
            }
            
            body(self)
            
            saveToPreferences { (error) in
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(self))
            }
        }
    }
}
