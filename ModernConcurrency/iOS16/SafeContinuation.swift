//
//  SafeContinuation.swift
//  ModernConcurrency
//
//  Created by Lucas van Dongen and Alexander Frolikov on 17/07/2025.
//

import Foundation

protocol Logging {
    func log(_ message: String)
}

struct SafeContinuation<T, E> where E: Error, T: Sendable {
    enum ContinuationState {
        case waiting
        case resumed([String])

        var callStack: [String] {
            switch self {
            case .waiting: []
            case let .resumed(stuff): stuff
            }
        }
    }

    private let checkedContinuation: CheckedContinuation<T, any Error>
    private let logging: Logging
    private var state: ContinuationState = .waiting

    init(
        checkedContinuation: CheckedContinuation<T, any Error>,
        logging: Logging
    ) {
        self.checkedContinuation = checkedContinuation
        self.logging = logging
    }

    mutating func resume(returning value: sending T) {
        guard case .waiting = state else {
            handleOverResumed(at: Thread.callStackSymbols)
            return
        }

        state = .resumed(Thread.callStackSymbols)
        checkedContinuation.resume(returning: value)
    }

    mutating func resume(throwing error: any Error) {
        guard case .waiting = state else {
            handleOverResumed(at: Thread.callStackSymbols)
            return
        }

        state = .resumed(Thread.callStackSymbols)
        checkedContinuation.resume(throwing: error)
    }

    mutating func resume(with result: Result<T, E>) {
        guard case .waiting = state else {
            handleOverResumed(at: Thread.callStackSymbols)
            return
        }

        state = .resumed(Thread.callStackSymbols)
        checkedContinuation.resume(with: result)
    }

    func handleOverResumed(at callStack: [String]) {
        logging.log(buildMessage(secondCallStack: callStack))
    }

    func buildMessage(secondCallStack: [String]) -> String {
        let firstStack = state.callStack.joined(separator: "\n")
        let secondStack = state.callStack.joined(separator: "\n")
        let baseMessage = "Continuation was resumed twice."
        return "\(baseMessage)\n\nFirst call:\n\(firstStack)\n\nSecond call:\n\(secondStack)"
    }
}
