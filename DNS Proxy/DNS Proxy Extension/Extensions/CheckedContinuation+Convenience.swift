//
//  CheckedContinuation+Convenience.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import Foundation

extension CheckedContinuation {
    func resume(catching resultResolver: () throws -> T) where E == Error {
        let result = Result {
            try resultResolver()
        }
        resume(with: result)
    }
}
