//
//  PacketTunnelProvider.swift
//  DNS Packet Tunnel Extension
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    override init() {
        if case .none = Logger.shared {
            Logger.shared = Logger(category: "extension")
        }
        super.init()
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        return completionHandler(nil)
        
        do {
            let options = try TunnelOptions(tunnelOptions: options)
            let networkSettings = NETunnelNetworkSettings(tunnelRemoteAddress: options.tunnelRemoteAddress)
            networkSettings.dnsSettings = options.dnsSettings
            setTunnelNetworkSettings(networkSettings) { error in
                completionHandler(error)
            }
        } catch {
            LogError("Tunnel start failed", error)
            return completionHandler(error)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        super.wake()
        // Add code here to wake up.
    }
}
