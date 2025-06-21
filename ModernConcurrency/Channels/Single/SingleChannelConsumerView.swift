//
//  SingleChannelConsumerView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import SwiftUI

struct SingleChannelConsumerView: View {
    @State private var publisher = SingleChannelPublisher()
    @State private var currentMessage: String?

    var body: some View {
        VStack {
            Text("Current message: \(currentMessage ?? "Waiting for message")")
            Button("Next Message") {
                let publisher = self.publisher
                Task { @MainActor in
                    await publisher.sendMessage()
                }
            }
        }
        .task {
            print("Starting task")
            for await message in publisher.channel {
                print("New Message received: \(message.rawValue)")
                currentMessage = message.rawValue
            }

            currentMessage = "Done receiving messages"
        }
    }
}
