//
//  MultiChannelFailConsumerView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import SwiftUI

struct MultiChannelFailConsumerView: View {
    @State private var publisher = SingleChannelPublisher()
    @State private var currentMessage1: String?
    @State private var currentMessage2: String?

    var body: some View {
        VStack {
            Text("Current message 1: \(currentMessage1 ?? "Waiting for message")")
            Text("Current message 2: \(currentMessage2 ?? "Waiting for message")")
            Button("Next Message") {
                let publisher = self.publisher
                Task { @MainActor in
                    await publisher.sendMessage()
                }
            }
        }
        .task {
            print("Starting task 1")
            for await message in publisher.channel {
                print("New Message received 1: \(message.rawValue)")
                currentMessage1 = message.rawValue
            }

            currentMessage1 = "Done receiving messages 1"
        }
        .task {
            print("Starting task 2")
            for await message in publisher.channel {
                print("New Message received 2: \(message.rawValue)")
                currentMessage2 = message.rawValue
            }

            currentMessage2 = "Done receiving messages 2"
        }
    }
}
