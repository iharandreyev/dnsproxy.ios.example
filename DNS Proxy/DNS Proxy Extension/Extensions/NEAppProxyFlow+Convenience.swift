//
//  NEAppProxyFlow+Convenience.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import NetworkExtension

extension NEAppProxyFlow {
    func open(withLocalEndpont localEndpoint: NWHostEndpoint? = nil) async throws {
        try await withCheckedThrowingContinuation { [weak self] (promise: CheckedContinuation<Void, Error>) in
            guard let self else {
                return promise.resume(throwing: NSError.unknown(thrownBy: Self.self))
            }
            self.open(withLocalEndpoint: localEndpoint) { error in
                promise.resume(with: Result(failure: error))
            }
        }
    }
}
