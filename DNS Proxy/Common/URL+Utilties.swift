//
//  URL+Utilties.swift
//  DNS Packet Tunnel Extension
//
//  Created by Andreyeu, Ihar on 1/26/23.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        guard let url = URL(string: value) else {
            fatalError("Invalid URL string `\(value)`")
        }
        self = url
    }
}
