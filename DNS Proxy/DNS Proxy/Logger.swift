//
//  Logger.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import Foundation

func Log(_ values: Any..., prefix: String = "[DNS Proxy]") {
    NSLog(prefix + ": " + values.map { "\($0)" }.joined(separator: " "))
}
