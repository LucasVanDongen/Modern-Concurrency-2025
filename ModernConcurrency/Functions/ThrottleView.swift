//
//  ThrottleView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 10/06/2025.
//

import AsyncAlgorithms
import SwiftUI

struct ThrottleView: View {
    @State var publisher: FunctionsPublisher
    @State var updatesChannel: AsyncChannel<String>
    @State var updatesDebouncedChannel: AsyncChannel<String>
    @State var updatesThrottledChannel: AsyncChannel<String>
    @State var updates = 0
    @State var updatesDebounced = 0
    @State var updatesThrottled = 0

    init(publisher: FunctionsPublisher) {
        self.publisher = publisher
        updatesChannel = publisher.channel.subscribe()
        updatesDebouncedChannel = publisher.channel.subscribe()
        updatesThrottledChannel = publisher.channel.subscribe()
    }

    var body: some View {
        VStack {
            Text("Updates: \(updates)")
            Text("Debounced updates: \(updatesDebounced)")
            Text("Throttled updates: \(updatesThrottled)")
            TextField("Start typing text here", text: $publisher.currentMessage)
        }
        .task {
            for await _ in updatesChannel {
                updates += 1
            }
        }
        .task {
            for await _ in updatesDebouncedChannel.debounce(for: .seconds(0.5)) {
                updatesDebounced += 1
            }
        }
        .task {
            for await _ in updatesThrottledChannel._throttle(for: .seconds(0.5)) {
                updatesThrottled += 1
            }
        }
    }
}
