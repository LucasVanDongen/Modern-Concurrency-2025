//
//  MultiCastConsumerView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import AsyncAlgorithms
import SwiftUI

struct MultiCastConsumerView: View {
    @State var channel: AsyncChannel<ChannelMessage>
    @State var publisher: MultiCastPublisher
    @State private var currentMessage: String?

    var body: some View {
        VStack {
            Text("Current message: \(currentMessage ?? "Waiting for message")")
            Button("Next Message") {
                // Needed to avoid Concurrency error
                let publisher = self.publisher
                Task { @MainActor in
                    await publisher.sendMessage()
                }
            }
        }
        .task {
            print("Starting task")
            for await message in channel {
                print("New Message received: \(message.rawValue)")
                currentMessage = message.rawValue
            }

            currentMessage = "Done receiving messages"
        }
    }
}
