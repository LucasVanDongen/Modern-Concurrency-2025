//
//  ModernConcurrencyApp.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import DefaultIsolation
import StandardIsolation
import SwiftUI

@main
struct ModernConcurrencyApp: App {
    @State var publisher = MultiCastPublisher()

    @State var actor: ActorState?

    var body: some Scene {
        WindowGroup {
            ScrollView {
                VStack {
                    Text("Observation").font(.title)
                    Text("Observable: Simple Model")
                    ObservableView()
                    Text("Observable: Model To ViewModel")
                    ObservableViewModelView()
                    Text("Observable: Model To UIKit")
                    ObservableLegacyViewControllerWrapper()
                        .frame(height: 50)
                    Text("Observations: Stream Model To UIKit")
                    ObservationsLegacyViewControllerWrapper()
                        .frame(height: 90)
                    Divider()
                    Text("AsyncAlgorithms").font(.title)
                    Text("Single Channel, one consumer: Works ✅")
                    SingleChannelConsumerView()
                    Text("Single Channel, multiple consumers: Fails 🚫")
                    MultiChannelFailConsumerView()
                    Text("Multi Channel, Multiple Consumers: Works ✅")
                    MultiCastConsumerView(channel: publisher.multicast.subscribe(), publisher: publisher)
                    MultiCastConsumerView(channel: publisher.multicast.subscribe(), publisher: publisher)
                    Divider()
                    Text("Debounce, Throttle and other functions").font(.title)
                    Text("Debounce and Throttle")
                    ThrottleView(publisher: FunctionsPublisher())
                    Divider()
                    Text("Standard vs Default Isolation").font(.title)
                    Text("Standard - like it was")
                    StandardContentView()
                    Text("Default - all on MainActor")
                    DefaultContentView()
                    if let actor {
                        Text("Global Custom Actor")
                        ActorView(state: actor)
                    } else {
                        Text("Loading Actor...")
                            .task { @TestActor in
                               let actor = ActorState()
                               Task { @MainActor in
                                   self.actor = actor
                               }
                            }
                    }
                }
            }
        }
    }
}
