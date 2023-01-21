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
        Log("New flow \(flow)")
        return true
    }

}
