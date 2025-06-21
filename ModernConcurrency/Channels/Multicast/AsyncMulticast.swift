//
//  AsyncMulticast.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 06/06/2025.
//

import AsyncAlgorithms

protocol AsyncMulticasting {
    associatedtype Element: Sendable

    /// Subscribe to the `AsyncMulticast`, returns your `AsyncChannel`
    func subscribe() -> AsyncChannel<Element>

    /// Sends an element to an awaiting iteration. This function will resume when the next call to `next()` is made
    /// or when a call to `finish()` is made from another task.
    /// If the channel is already finished then this returns immediately.
    /// If the task is cancelled, this function will resume without sending the element.
    /// Other sending operations from other tasks will remain active.
    func send(_ element: Element) async

    /// Immediately resumes all the suspended operations.
    /// All subsequent calls to `next(_:)` will resume immediately.
    func finish()
}

class AsyncMulticast<Element: Sendable>: AsyncMulticasting {
    private var channels = [Weak<AsyncChannel<Element>>]()

    typealias Element = Element

    /// Subscribe to the `AsyncMulticast`, returns your `AsyncChannel`
    func subscribe() -> AsyncChannel<Element> {
        let channel = AsyncChannel<Element>()

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

    /// Immediately resumes all the suspended operations.
    /// All subsequent calls to `next(_:)` will resume immediately.
    func finish() {
        for channel in channels {
            channel.value?.finish()
        }
    }
}
