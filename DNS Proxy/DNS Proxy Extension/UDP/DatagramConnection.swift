//
//  DatagramConnection.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import Foundation
import Network

private extension DispatchQueue {
    static let datagramConnection = DispatchQueue(
        label: "example.dns.proxy.DNS-Proxy-Extension.datagram-connection",
        qos: .userInteractive,
        attributes: .concurrent
    )
}

actor DatagramConnection {
    private let connection: NWConnection
    private let datagram: Datagram
    
    init(_ datagram: Datagram) throws {
        self.datagram = datagram
        
        switch datagram.endpoint {
        case let .host(hostEndpoint):
            guard let port = Network.NWEndpoint.Port(hostEndpoint.port) else {
                throw NSError.unknown(thrownBy: Self.self)
            }
            let host = Network.NWEndpoint.Host(hostEndpoint.hostname)
            connection = NWConnection(host: host, port: port, using: .udp)
        case .bonjour:
            throw NSError.unknown(thrownBy: Self.self)
        }
    }
    
    func transferData() async throws -> Datagram {
        Log("Will perform transfers for UDP datagram `\(datagram)`")
        try await connection.establish(on: .datagramConnection)
        Log("Did establish connection for `\(datagram)`")
        try await connection.send(content: datagram.packet)
        Log("Did send packet for `\(datagram)`")
        let message = try await connection.receiveMessage()
        Log("Did receive message for `\(datagram)`")
        return Datagram(packet: message.completeContent, endpoint: datagram.endpoint)
    }
}
