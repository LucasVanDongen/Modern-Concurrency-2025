//
//  ThrowingStreamViewModel.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 17/07/2025.
//

import Observation

@Observable
@MainActor
class ThrowingStreamViewModel {
    @ObservationIgnored
    private let model = BlockBasedModel()
    private(set) var currentMessage = "No Message"

    func buttonPressed() async throws {
        for try await message in sendMessage() {
            currentMessage = message
        }
    }

    func sendMessage() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            model.sendMessage { result in
                continuation.yield(with: result)
            }
        }
    }
}
