//
//  Datagram.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/24/23.
//

import Foundation
import NetworkExtension

struct Datagram {
    enum Endpoint {
        case host(NWHostEndpoint)
        case bonjour(NWBonjourServiceEndpoint)
        
        func eraseToEndpoint() -> NetworkExtension.NWEndpoint {
            switch self {
            case let .host(endpoint): return endpoint
            case let .bonjour(endpoint): return endpoint
            }
        }
    }
    
    let packet: Data
    let endpoint: Endpoint
    
    init(packet: Data, endpoint: NetworkExtension.NWEndpoint) throws {
        guard !packet.isEmpty else {
            throw NSError.unknown(thrownBy: Self.self)
        }
        
        switch endpoint {
        case let host as NWHostEndpoint:
            self.endpoint = .host(host)
        case let bonjour as NWBonjourServiceEndpoint:
            self.endpoint = .bonjour(bonjour)
        default:
            throw NSError.unknown(thrownBy: Self.self)
        }
        
        self.packet = packet
    }
    
    init(packet: Data, endpoint: Endpoint) {
        self.packet = packet
        self.endpoint = endpoint
    }
}
