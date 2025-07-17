//
//  SafeContinuationViewModel.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 17/07/2025.
//

import Combine

@MainActor
class ContinuationViewModel: ObservableObject {
    private let model = BlockBasedModel()

    @Published private(set) var currentMessage = "No Message"

    func sendMessage() async throws {
        try await withCheckedThrowingContinuation { continuation in
            model.sendMessage { result in
                continuation.resume(with: result)
            }
        }
    }
}
