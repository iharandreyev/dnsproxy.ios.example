//
//  Logger.swift
//  DNS Proxy
//
//  Created by Andreyeu, Ihar on 1/21/23.
//

import Foundation
import os.log

enum LogType {
    case info
    case debug
    case error
    
    fileprivate func eraseToOSLogType() -> OSLogType {
        switch self {
        case .info: return .info
        case .debug: return .debug
        case .error: return .error
        }
    }
}

struct Logger {
    private let log: OSLog
    
    init(subsystem: String = Bundle.main.name(), category: String) {
        log = OSLog(subsystem: subsystem, category: category)
    }
    
    /* Format
    os_log("User %{public}@ logged in", log: OSLog.userFlow, type: .info, username)
    os_log("User %{private}@ logged in", log: OSLog.userFlow, type: .info, username)
     */
    
    func log(_ type: LogType = .info, _ message: StaticString) {
        os_log(message, log: log, type: type.eraseToOSLogType())
    }


    func log(_ type: LogType = .info, _ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: log, type: type.eraseToOSLogType(), args)
    }

    func logError(_ message: String, _ error: Error) {
        log(.error, "%{public}@: %{public}@", message, "\(error)")
    }
}

extension Logger {
    static var shared: Logger!
}

func Log(_ type: LogType, _ message: StaticString) {
    Logger.shared.log(type, message)
}

func Log(_ message: StaticString) {
    Logger.shared.log(.info, message)
}

func Log(_ type: LogType, message: StaticString, _ args: CVarArg...) {
    Logger.shared.log(type, message, args)
}

func Log(message: StaticString, _ args: CVarArg...) {
    Logger.shared.log(.info, message, args)
}

func LogError(_ message: String, _ error: Error) {
    Logger.shared.logError(message, error)
}
