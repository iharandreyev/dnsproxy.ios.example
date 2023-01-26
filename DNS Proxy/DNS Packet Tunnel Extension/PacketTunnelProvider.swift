//
//  PacketTunnelProvider.swift
//  DNS Packet Tunnel Extension
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
//        var networkSettings = NETunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
//        networkSettings.dnsSettings = DNSConfig.google().settings

//        setTunnelNetworkSettings(networkSettings) { error in
//            completionHandler(error)
//        }
        
        completionHandler(nil)
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

//- (NEPacketTunnelNetworkSettings *)getNetworkSettings {
//    NSUserDefaults *defs = [self sharedDefs];
//
//    BOOL hasIPv4 = NO;
//    BOOL hasIPv6 = NO;
//
//    NSString *net_type = [defs stringForKey:@"netType"];
//
//    if (net_type == nil) { //IPv4 by default
//        net_type = @"2";
//    }
//
//    if ([net_type isEqualToString:@"1"]) {
//        hasIPv6 = YES;
//        hasIPv4 = YES;
//    } else if ([net_type isEqualToString:@"2"]) {
//        hasIPv4 = YES;
//    } else if ([net_type isEqualToString:@"3"]) {
//        hasIPv6 = YES;
//    } else {
//        NSInteger net_status = [NetTester status];
//        if (net_status == NET_TESTER_IPV6_CONN) {
//            hasIPv6 = YES;
//        } else if (net_status == NET_TESTER_DUAL_CONN) {
//            hasIPv6 = YES;
//            hasIPv4 = YES;
//        } else {
//            hasIPv4 = YES;
//        }
//    }
//
//    NEPacketTunnelNetworkSettings *networkSettings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress: hasIPv6 ? @"::1" : @"127.0.0.1" ];
//
//    BOOL showIcon = [defs boolForKey:@"showIcon"];
//
//    if (showIcon) {
//        if (hasIPv4) {
//            NEIPv4Settings *ipv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"192.0.2.1"] subnetMasks:@[@"255.255.255.0"]];
//            networkSettings.IPv4Settings = ipv4Settings;
//        }
//
//        if (hasIPv6) {
//            NEIPv6Settings *ipv6Settings = [[NEIPv6Settings alloc] initWithAddresses:@[@"fdc1:c10:ac:1::1"] networkPrefixLengths:@[@(64)]];
//            networkSettings.IPv6Settings = ipv6Settings;
//        }
//    }
//
//    NEDNSSettings *dnsSettings;
//    if (hasIPv4 && hasIPv6) {
//        dnsSettings = [[NEDNSSettings alloc] initWithServers: @[@"127.0.0.1", @"::1"]];
//    } else if (hasIPv6) {
//        dnsSettings = [[NEDNSSettings alloc] initWithServers: @[@"::1"]];
//    } else {
//        dnsSettings = [[NEDNSSettings alloc] initWithServers: @[@"127.0.0.1"]];
//    }
//
//    dnsSettings.matchDomains = @[@""];
//    networkSettings.DNSSettings = dnsSettings;
//
//    return networkSettings;
//}
