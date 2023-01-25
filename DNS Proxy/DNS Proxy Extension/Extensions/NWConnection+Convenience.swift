//
//  NWConnection+Convenience.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import Foundation
import Network

extension NWConnection {
    func establish(on queue: DispatchQueue) async throws {
        try await withCheckedThrowingContinuation { [weak self] (promise: CheckedContinuation<Void, Error>) in
            guard let self else {
                return promise.resume(throwing: NSError.unknown(thrownBy: Self.self))
            }
            
            func finish(with result: Result<Void, Error>) {
                promise.resume(with: result)
            }

            self.stateUpdateHandler = { state in
                switch state {
                case .setup:
                    return
                case .waiting:
                    return
                case .preparing:
                    return
                case .ready:
                    return finish(with: .success(()))
                case let .failed(error):
                    return finish(with: .failure(error))
                case .cancelled:
                    return finish(with: .failure(NSError.cancel(thrownBy: Self.self)))
                @unknown default:
                    assertionFailure("Unknown connection state \(state)")
                    return finish(with: .failure(NSError.unknown(thrownBy: Self.self)))
                }
            }
            
            start(queue: queue)
        }
    }
    
    func send<Content: DataProtocol>(
        content: Content?,
        contentContext: NWConnection.ContentContext = .defaultMessage,
        isComplete: Bool = true
    ) async throws {
        try await withCheckedThrowingContinuation { [weak self] (promise: CheckedContinuation<Void, Error>) in
            guard let self else {
                return promise.resume(throwing: NSError.unknown(thrownBy: Self.self))
            }
            
            self.send(
                content: content,
                contentContext: contentContext,
                isComplete: isComplete,
                completion: .contentProcessed { error in
                    promise.resume(with: Result(success: (), failure: error))
                })
        }
    }
    
    struct Message {
        let completeContent: Data
        let contentContext: ContentContext?
        let isComplete: Bool
        
        fileprivate init(completeContent: Data?, contentContext: ContentContext?, isComplete: Bool) throws {
            guard let completeContent = completeContent, !completeContent.isEmpty else {
                throw NSError.unknown(thrownBy: Self.self)
            }
            self.completeContent = completeContent
            self.contentContext = contentContext
            self.isComplete = isComplete
        }
    }
    
    func receiveMessage() async throws -> Message {
        try await withCheckedThrowingContinuation { [weak self] (promise: CheckedContinuation<Message, Error>) in
            guard let self else {
                return promise.resume(throwing: NSError.unknown(thrownBy: Self.self))
            }
            
            self.receiveMessage { completeContent, contentContext, isComplete, error in
                if let error {
                    return promise.resume(throwing: error)
                }
                
                promise.resume {
                    try Message(
                        completeContent: completeContent,
                        contentContext: contentContext,
                        isComplete: isComplete
                    )
                }
            }
        }
    }
}
