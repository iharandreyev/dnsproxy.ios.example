//
//  Collection+Parallel.swift
//  DNS Proxy Extension
//
//  Created by Andreyeu, Ihar on 1/25/23.
//

import Foundation

// https://gist.github.com/wilg/47a04c8f5083a6938da6087f77333784
extension Collection {
    func parallelMap<T>(
        parallelism: Int = 2,
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        guard !isEmpty else { return [] }
        let count = count
        return try await withThrowingTaskGroup(of: (Int, T).self, returning: [T].self) { group in
            var buffer = [T?](repeatElement(nil, count: count))

            var i = self.startIndex
            var submitted = 0

            func submitNext() async throws {
                if i == self.endIndex { return }

                group.addTask { [submitted, i] in
                    let value = try await transform(self[i])
                    return (submitted, value)
                }
                submitted += 1
                formIndex(after: &i)
            }

            // submit first initial tasks
            for _ in 0 ..< parallelism {
                try await submitNext()
            }

            // as each task completes, submit a new task until we run out of work
            while let (index, taskResult) = try await group.next() {
                buffer[index] = taskResult

                try Task.checkCancellation()
                try await submitNext()
            }
            
            let result = buffer.compactMap { $0 }
            assert(result.count == count)
            return result
        }
    }

    func parallelEach(
        parallelism: Int = 2,
        _ work: @escaping (Element) async throws -> Void
    ) async rethrows {
        _ = try await parallelMap(parallelism: parallelism) {
            try await work($0)
        }
    }
}
