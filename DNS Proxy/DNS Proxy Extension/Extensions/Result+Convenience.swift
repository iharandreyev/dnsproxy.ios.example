//
//  Result+Convenience.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import Foundation

extension Result {
    init(success: Success?, failure: Error?) where Failure == Error {
        if let failure {
            self = .failure(failure)
        } else if let success {
            self = .success(success)
        } else {
            self = .failure(NSError.unknown(thrownBy: Self.self))
        }
    }
    
    init(failure: Error?) where Success == Void, Failure == Error {
        self.init(success: (), failure: failure)
    }
}
