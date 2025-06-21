//
//  MultiCastPublisher.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import AsyncAlgorithms

class MultiCastPublisher {
    let multicast = AsyncMulticast<ChannelMessage>()

    private var messages = ChannelMessage.allCases

    func sendMessage() async {
        guard !messages.isEmpty else {
            multicast.finish()
            return
        }

        let nextMessage = messages.removeFirst()
        await multicast.send(nextMessage)
    }
}
