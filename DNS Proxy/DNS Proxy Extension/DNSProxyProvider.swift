//
//  DNSProxyProvider.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import NetworkExtension

class DNSProxyProvider: NEDNSProxyProvider {
    override init() {
        Log("Will init proxy provider")
        super.init()
        Log("Did init proxy provider")
    }

    override func startProxy(options:[String: Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        Log("Will start provider")
        completionHandler(nil)
        Log("Did start provider")
    }

    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        Log("Will stop proxy provider")
        completionHandler()
        Log("Did stop proxy provider")
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        Log("Proxy provider will sleep")
        completionHandler()
        Log("Proxy provider did go to sleep")
    }

    override func wake() {
        Log("Proxy provider did wake")
    }

    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        switch flow {
        case let tcpFlow as NEAppProxyTCPFlow:
            return handleNewFlow(tcpFlow)
        case let udpFlow as NEAppProxyUDPFlow:
            return handleNewFlow(udpFlow)
        default:
            assertionFailure("Invalid flow \(flow)")
            return false
        }
    }

    private func handleNewFlow(_ flow: NEAppProxyUDPFlow) -> Bool {
        Task(priority: .high) {
            do {
                try await handleNewFlow(flow)
            } catch {
                Log("Failed to handle \(flow)")
            }
        }
        return true
    }
    
    private func handleNewFlow(_ flow: NEAppProxyUDPFlow) async throws {
        Log("Will handle flow \(flow)")
        
        do {
            try await flow.open(withLocalEndpoint: flow.localEndpoint as? NWHostEndpoint)
            Log("Did open flow \(flow)")
            let datagrams = try await flow.readDatagrams()
            
            Log("Did read datagrams for flow \(flow)")
            datagrams.forEach {
                Log("\($0)")
            }

            let results = try await datagrams.parallelMap {
                let connection = try DatagramConnection($0)
                return try await connection.transferData()
            }
            
            try await flow.writeDatagrams(results)
            
            Log("Did write datagrams for flow \(flow)")
            
            flow.closeReadWithError(nil)
            flow.closeWriteWithError(nil)
            
            Log("Did handle flow \(flow)")
            
        } catch {
            Log("Did fail to handle flow \(flow): \(error)")
            
            flow.closeReadWithError(error)
            flow.closeWriteWithError(error)
            throw error
        }
    }
    
    private func handleNewFlow(_ flow: NEAppProxyTCPFlow) -> Bool {
        Log("Invalid flow \(flow). TCP flows are not supported yet")
        return false
    }
}
