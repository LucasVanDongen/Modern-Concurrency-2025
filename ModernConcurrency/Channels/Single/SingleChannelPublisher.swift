//
//  SingleChannelPublisher.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import AsyncAlgorithms

class SingleChannelPublisher {
    let channel = AsyncChannel<ChannelMessage>()

    private var messages = ChannelMessage.allCases

    func sendMessage() async {
        guard !messages.isEmpty else {
            channel.finish()
            return
        }

        await channel.send(messages.removeFirst())
    }
}
