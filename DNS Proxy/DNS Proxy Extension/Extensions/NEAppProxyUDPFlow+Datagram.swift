//
//  NEAppProxyUDPFlow+Datagram.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import Foundation
import NetworkExtension

extension NEAppProxyUDPFlow {
    func readDatagrams() async throws -> [Datagram] {
        try await withCheckedThrowingContinuation { [weak self] (promise: CheckedContinuation<[Datagram], Error>) in
            guard let self else {
                return promise.resume(throwing: NSError.unknown(thrownBy: Self.self))
            }
            self.readDatagrams { datagrams, endpoints, error in
                switch (datagrams, endpoints, error) {
                case let (.some(datagrams), .some(endpoints), .none):
                    let datagrams = zip(datagrams, endpoints).compactMap {
                        try? Datagram.init(packet: $0, endpoint: $1)
                    }
                    promise.resume(returning: datagrams)
                default:
                    promise.resume(with: Result(success: nil, failure: error))
                }
            }
        }
    }
    
    func writeDatagrams(_ datagrams: [Datagram]) async throws {
        try await withCheckedThrowingContinuation { [weak self] (promise: CheckedContinuation<Void, Error>) in
            guard let self else {
                return promise.resume(throwing: NSError.unknown(thrownBy: Self.self))
            }
            
            let (packets, endpoints) = datagrams.reduce(into: ([Data](), [NWEndpoint]())) {
                $0.0.append($1.packet)
                $0.1.append($1.endpoint.eraseToEndpoint())
            }
            
            self.writeDatagrams(packets, sentBy: endpoints) { error in
                promise.resume(with: Result(failure: error))
            }
        }
    }
}
