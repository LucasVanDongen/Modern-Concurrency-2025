//
//  FunctionsPublisher.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 10/06/2025.
//

import AsyncAlgorithms
import Observation

@Observable
@MainActor
class FunctionsPublisher {
    let channel = AsyncMulticast<String>()
    var currentMessage = "" {
        didSet {
            Task {
                await sendCurrent()
            }
        }
    }

    func sendCurrent() {
        Task { [weak channel] in
            await channel?.send(currentMessage)
        }
    }
}
