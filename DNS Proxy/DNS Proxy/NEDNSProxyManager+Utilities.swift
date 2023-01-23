//
//  NEDNSProxyManager+Utilities.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import Combine
import NetworkExtension

extension NEDNSProxyManager {
    func updateConfiguration(_ body: @escaping (NEDNSProxyManager) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        loadFromPreferences { [unowned self] error in
            if let error, let proxyError = DNSProxyError(error) {
                completion(.failure(proxyError))
                return
            }
            
            body(self)
            
            saveToPreferences { (error) in
                if let error, let proxyError = DNSProxyError(error) {
                    completion(.failure(proxyError))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    func isEnabledPublisher() -> AnyPublisher<Bool, Never> {
        NotificationCenter.default
            .publisher(for: NSNotification.Name.NEDNSProxyConfigurationDidChange)
            .compactMap { [weak self] notification in
                guard let self else { return nil }
                return self.isEnabled
            }
            .eraseToAnyPublisher()
    }
}

@available (iOS 11.0, *)
enum DNSProxyError: Error {
    /// The DNS proxy configuration is invalid
    case configurationInvalid
    /// The DNS proxy configuration is not enabled.
    case configurationDisabled
    /// The DNS proxy configuration needs to be loaded.
    case configurationStale
    /// The DNS proxy configuration cannot be removed.
    case configurationCannotBeRemoved
    
    case unknown
    
    init?(_ error: Error) {
        switch error {
        case let error as NSError:
            switch NEDNSProxyManagerError(rawValue: error.code) {
            case .configurationInvalid:
                self = .configurationInvalid
                return
            case .configurationDisabled:
                self = .configurationDisabled
                return
            case .configurationStale:
                self = .configurationStale
                return
            case .configurationCannotBeRemoved:
                self = .configurationCannotBeRemoved
                return
            case .none:
                return nil
            @unknown default:
                break
            }
        default:
            break
        }
        assertionFailure("Invalid error \(error)")
        return nil
    }
}
