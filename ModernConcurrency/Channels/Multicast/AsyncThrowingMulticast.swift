//
//  AsyncThrowingMulticast.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 06/06/2025.
//

import AsyncAlgorithms

protocol AsyncThrowingMulticasting {
    associatedtype Element: Sendable
    associatedtype ThrownError: Error
    // associatedtype Failure: Error

    /// Subscribe to the `AsyncThrowingMulticast`, returns your `AsyncThrowingChannel`
    func subscribe() -> AsyncThrowingChannel<Element, ThrownError>

    /// Sends an element to an awaiting iteration. This function will resume when the next call to `next()` is made
    /// or when a call to `finish()` is made from another task.
    /// If the channel is already finished then this returns immediately.
    /// If the task is cancelled, this function will resume without sending the element.
    /// Other sending operations from other tasks will remain active.
    func send(_ element: Element) async

    /// Sends an error to all awaiting iterations.
    /// All subsequent calls to `next(_:)` will resume immediately.
    func fail(_ error: ThrownError)

    /// Immediately resumes all the suspended operations.
    /// All subsequent calls to `next(_:)` will resume immediately.
    func finish()
}

class AsyncThrowingMulticast: AsyncThrowingMulticasting {
    private var channels = [Weak<AsyncThrowingChannel<Element, ThrownError>>]()

    typealias Element = Sendable
    typealias ThrownError = any Error

    /// Subscribe to the `AsyncThrowingChannel`, returns your `AsyncThrowingChannel`
    func subscribe() -> AsyncThrowingChannel<Element, ThrownError> {
        let channel = AsyncThrowingChannel<Element, ThrownError>()

        channels = channels.filter { $0.value != nil } + [Weak(value: channel)]

        return channel
    }

    /// Sends an element to an awaiting iteration. This function will resume when the next call to `next()` is made
    /// or when a call to `finish()` is made from another task.
    /// If the channel is already finished then this returns immediately.
    /// If the task is cancelled, this function will resume without sending the element.
    /// Other sending operations from other tasks will remain active.
    func send(_ element: Element) async {
        for channel in channels {
            await channel.value?.send(element)
        }
    }

    /// Sends an error to all awaiting iterations.
    /// All subsequent calls to `next(_:)` will resume immediately.
    func fail(_ error: ThrownError) {
        for channel in channels {
            channel.value?.fail(error)
        }
    }

    /// Immediately resumes all the suspended operations.
    /// All subsequent calls to `next(_:)` will resume immediately.
    func finish() {
        for channel in channels {
            channel.value?.finish()
        }
    }
}
