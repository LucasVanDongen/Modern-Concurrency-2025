//
//  ActorView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 20/06/2025.
//

import AsyncAlgorithms
import ObservationSequence
import SwiftUI

@MainActor
struct ActorView: View {
    @TestActor
    @State
    var state: ActorState

    //@State private var value: String = "Waiting..."
    @State private var stream: String = "Waiting..."
    @State private var channel: String = "Waiting..."

    var body: some View {
        //Text("Value: \(state.value)")
        Text("Value: \(stream)")
        Text("Value: \(channel)")
        Button("Next Message") {
        Task {
                await state.sendMessage()
            }
        }
        .task { @TestActor in
            for await message in state.stream {
                Task { @MainActor in
                    stream = message.rawValue
                }
            }
        }
        .task { @TestActor in
            for await message in state.channel {
                Task { @MainActor in
                    channel = message.rawValue
                }
            }
        }
    }
}

@TestActor
@Observable
class ActorState {
    @ObservationIgnored
    let channel = AsyncChannel<ChannelMessage>()
    @ObservationIgnored
    var stream: Observations<ChannelMessage, Never>!
    var value: ChannelMessage = .one

    private var messages = ChannelMessage.allCases

    init() {
        stream = Observations { self.value }
    }

    func sendMessage() async {
        guard !messages.isEmpty else {
            channel.finish()
            return
        }

        let nextMessage = messages.removeFirst()
        value = nextMessage
        await channel.send(nextMessage)
    }
}
